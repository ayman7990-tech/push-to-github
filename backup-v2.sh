#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# 💾 نسخة احتياطية شاملة (نسخة محدثة)
# ============================================

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=~/termux-backup-$DATE
mkdir -p "$BACKUP_DIR"

echo ""
echo "═══════════════════════════════════════════"
echo "💾 نسخة احتياطية شاملة v2"
echo "📅 التاريخ: $DATE"
echo "═══════════════════════════════════════════"
echo ""

# 1. نسخ مجلد projects كامل
echo "📁 نسخ مجلد المشاريع..."
if [ -d ~/projects ]; then
    rsync -a --exclude='node_modules' --exclude='.git' \
          ~/projects "$BACKUP_DIR/" 2>/dev/null || \
    cp -r ~/projects "$BACKUP_DIR/" 2>/dev/null
    PROJ_COUNT=$(find "$BACKUP_DIR/projects" -type f 2>/dev/null | wc -l)
    echo "   ✅ $PROJ_COUNT ملف"
fi
echo ""

# 2. نسخ السكربتات الرئيسية
echo "📝 نسخ السكربتات..."
mkdir -p "$BACKUP_DIR/scripts"
cp ~/*.sh "$BACKUP_DIR/scripts/" 2>/dev/null
cp ~/*.py "$BACKUP_DIR/scripts/" 2>/dev/null
echo "   ✅ $(ls "$BACKUP_DIR/scripts/" 2>/dev/null | wc -l) ملف"
echo ""

# 3. نسخ الملفات السرية
echo "🔐 نسخ المفاتيح..."
mkdir -p "$BACKUP_DIR/secrets"
[ -f ~/.groq-key ] && cp ~/.groq-key "$BACKUP_DIR/secrets/" 2>/dev/null
[ -f ~/.secrets/.groq-key ] && cp ~/.secrets/.groq-key "$BACKUP_DIR/secrets/groq-key" 2>/dev/null
[ -f ~/.gitconfig ] && cp ~/.gitconfig "$BACKUP_DIR/secrets/" 2>/dev/null
[ -f ~/.bashrc ] && cp ~/.bashrc "$BACKUP_DIR/secrets/" 2>/dev/null
[ -d ~/.config ] && cp -r ~/.config "$BACKUP_DIR/secrets/config" 2>/dev/null
[ -d ~/.ssh ] && cp -r ~/.ssh "$BACKUP_DIR/secrets/ssh" 2>/dev/null
echo "   ✅ تم"
echo ""

# 4. نسخ ملفات الإعدادات
echo "📋 نسخ الملفات الرئيسية..."
cp ~/README.md ~/PROJECT-NOTES.md ~/*.html "$BACKUP_DIR/" 2>/dev/null
echo "   ✅ تم"
echo ""

# 5. ضغط
echo "🗜️  ضغط النسخة..."
cd ~
ARCHIVE_NAME="termux-backup-$DATE.tar.gz"
tar -czf "$ARCHIVE_NAME" "termux-backup-$DATE/" 2>/dev/null
SIZE=$(du -h "$ARCHIVE_NAME" | cut -f1)
FILE_COUNT=$(tar -tzf "$ARCHIVE_NAME" 2>/dev/null | wc -l)
rm -rf "$BACKUP_DIR"

echo "   ✅ تم الضغط"
echo ""

# 6. النتائج
echo "═══════════════════════════════════════════"
echo "🎉 تم الحفظ!"
echo "═══════════════════════════════════════════"
echo ""
echo "📦 الملف: ~/$ARCHIVE_NAME"
echo "📏 الحجم: $SIZE"
echo "📄 عدد الملفات: $FILE_COUNT"
echo ""

if [ "$FILE_COUNT" -lt 100 ]; then
    echo "⚠️  تحذير: عدد الملفات قليل!"
    echo "   المفروض يكون 1000+"
fi

echo "🔍 لاستعراض المحتويات:"
echo "   tar -tzf ~/$ARCHIVE_NAME | head -30"
echo ""
echo "═══════════════════════════════════════════"
