#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# 🐙 رفع مشروع على GitHub
# ============================================
# الاستخدام:
#   bash ~/push-to-github.sh                    (يرفع آخر مشروع في المكان الحالي)
#   bash ~/push-to-github.sh اسم-المستودع       (يرفع باسم مخصص)
#   bash ~/push-to-github.sh المسار اسم-المستودع (يرفع مشروع معين)
# ============================================

# الألوان
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "═══════════════════════════════════════════"
echo "🐙 رفع مشروع على GitHub"
echo "═══════════════════════════════════════════"
echo ""

# 1. تحديد المسار
if [ -n "$1" ] && [ -d "$1" ]; then
    PROJECT_DIR="$1"
    shift
elif [ "$1" = "." ] || [ -d "./.git" ] || [ -f "./package.json" ] || [ -f "./server.js" ]; then
    PROJECT_DIR="."
else
    PROJECT_DIR="."
fi

cd "$PROJECT_DIR" || exit 1
CURRENT_DIR=$(basename "$(pwd)")

# 2. اسم المستودع
if [ -n "$1" ]; then
    REPO_NAME="$1"
else
    # تنظيف الاسم
    REPO_NAME=$(echo "$CURRENT_DIR" | sed 's/[^a-zA-Z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//' | tr '[:upper:]' '[:lower:]')
fi

echo -e "📁 المشروع: ${BLUE}$CURRENT_DIR${NC}"
echo -e "📦 المستودع: ${BLUE}$REPO_NAME${NC}"
echo ""

# 3. التحقق من التوكن
TOKEN_FILE=~/.config/termux-github/token.txt
if [ ! -f "$TOKEN_FILE" ]; then
    echo -e "${RED}❌ التوكن مش موجود!${NC}"
    echo "   اتأكد من: $TOKEN_FILE"
    exit 1
fi

TOKEN_LINE=$(cat "$TOKEN_FILE")
USER=$(echo "$TOKEN_LINE" | cut -d: -f1)
TOK=$(echo "$TOKEN_LINE" | cut -d: -f2)

if [ -z "$USER" ] || [ -z "$TOK" ]; then
    echo -e "${RED}❌ التوكن غلط!${NC}"
    exit 1
fi

echo -e "👤 المستخدم: ${GREEN}$USER${NC}"
echo ""

# 4. التحقق من الاتصال
echo "🔍 التحقق من الاتصال بـ GitHub..."
STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: token $TOK" \
    https://api.github.com/user)

if [ "$STATUS" != "200" ]; then
    echo -e "${RED}❌ فشل الاتصال (HTTP $STATUS)${NC}"
    exit 1
fi
echo -e "${GREEN}✅ الاتصال شغال${NC}"
echo ""

# 5. إنشاء .gitignore لو مش موجود
if [ ! -f ".gitignore" ]; then
    echo "📝 إنشاء .gitignore..."
    cat > .gitignore << 'EOF'
node_modules/
*.log
data/orders.json
.DS_Store
EOF
    echo -e "${GREEN}   ✅ تم${NC}"
    echo ""
fi

# 6. تهيئة Git
if [ ! -d ".git" ]; then
    echo "🔧 تهيئة Git..."
    git init -q
    git branch -M main
    git config user.email "$USER@users.noreply.github.com"
    git config user.name "$USER"
    echo -e "${GREEN}   ✅ تم${NC}"
else
    echo "ℹ️  Git مهيأ من قبل"
fi
echo ""

# 7. إضافة الملفات
echo "📦 إضافة الملفات..."
git add -A
COMMIT_MSG="🎉 Update: $(date +'%Y-%m-%d %H:%M')"
git commit -m "$COMMIT_MSG" -q 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✅ تم Commit${NC}"
else
    echo -e "${YELLOW}   ⚠️  مفيش تغييرات جديدة${NC}"
fi
echo ""

# 8. إنشاء المستودع على GitHub
echo "🌐 إنشاء المستودع على GitHub..."
CREATE=$(curl -s -X POST https://api.github.com/user/repos \
    -H "Authorization: token $TOK" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"$REPO_NAME\",\"private\":false,\"auto_init\":false}")

if echo "$CREATE" | grep -q '"id"'; then
    echo -e "${GREEN}   ✅ تم إنشاء المستودع${NC}"
elif echo "$CREATE" | grep -q "already exists"; then
    echo -e "${YELLOW}   ℹ️  المستودع موجود من قبل${NC}"
else
    echo -e "${YELLOW}   ⚠️  تحذير: ${CREATE:0:100}${NC}"
fi
echo ""

# 9. الرفع
echo "🚀 جاري الرفع..."
git remote remove origin 2>/dev/null
git remote add origin "https://github.com/$USER/$REPO_NAME.git"

PUSH_URL="https://$USER:$TOK@github.com/$USER/$REPO_NAME.git"
PUSH_OUTPUT=$(git push "$PUSH_URL" main -u --force 2>&1)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✅ تم الرفع${NC}"
else
    echo -e "${RED}   ❌ فشل الرفع${NC}"
    echo "$PUSH_OUTPUT" | head -5
    exit 1
fi
echo ""

# 10. إخفاء التوكن
git remote set-url origin "https://github.com/$USER/$REPO_NAME.git"

# 11. النتيجة النهائية
echo "═══════════════════════════════════════════"
echo -e "${GREEN}🎉 تم بنجاح!${NC}"
echo "═══════════════════════════════════════════"
echo ""
echo -e "🌐 ${BLUE}https://github.com/$USER/$REPO_NAME${NC}"
echo ""
echo "📊 إحصائيات:"
echo "   📁 مجلد: $CURRENT_DIR"
echo "   📦 مستودع: $REPO_NAME"
echo "   👤 مستخدم: $USER"
echo "   🕐 وقت: $(date +'%H:%M:%S')"
echo ""
