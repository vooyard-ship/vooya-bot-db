#!/bin/bash
# DB 파일 변경 감지 → 자동 복사 + GitHub push

DB_SOURCE="/Users/max1/Library/Mobile Documents/iCloud~md~obsidian/Documents/VOOYAi/workspace/40-49_personal/47_family"
DB_REPO="/Users/max1/vooya-bot-db"
FILES=("menu_db.md" "fridge_db.md" "daycare_menu_2026_04.md")

echo "DB 파일 감시 시작..."

/opt/homebrew/bin/fswatch -o "${DB_SOURCE}/menu_db.md" "${DB_SOURCE}/fridge_db.md" "${DB_SOURCE}/daycare_menu_2026_04.md" | while read; do
    sleep 2  # 저장 완료 대기
    changed=false
    for f in "${FILES[@]}"; do
        src="${DB_SOURCE}/${f}"
        dst="${DB_REPO}/${f}"
        if [ -f "$src" ] && ! diff -q "$src" "$dst" > /dev/null 2>&1; then
            cp "$src" "$dst"
            changed=true
        fi
    done

    if [ "$changed" = true ]; then
        cd "$DB_REPO"
        git add .
        git commit -m "DB 자동 업데이트 $(date '+%Y-%m-%d %H:%M')"
        git push origin main
        echo "✅ GitHub 업데이트 완료 $(date '+%H:%M')"
    fi
done
