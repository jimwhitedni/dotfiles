#!/bin/bash

echo "=== 🟢 有在聽 Port 的 (通常要留) ==="
lsof -i -P 2>/dev/null | grep -i listen | grep node | awk '{print $2, $9}'

echo ""
echo "=== 🧟 孤兒進程 (父進程已死，可刪) ==="
ps -eo pid,ppid,command | grep '[n]ode' | awk '$2==1 {print $1, $3}'

echo ""
echo "=== ⏰ 跑超過 1 小時的 (可能忘記關) ==="
ps -eo pid,etime,command | grep '[n]ode' | awk '{
  split($2, t, /[-:]/)
  if (length(t) >= 3) print "PID:", $1, "時間:", $2
}'

echo ""
echo "=== 📁 各目錄的 node 數量 ==="
for pid in $(pgrep node); do
  lsof -p $pid 2>/dev/null | awk '$4=="cwd" {print $9}'
done | sort | uniq -c | sort -rn

echo ""
echo "=== 🔪 清理指令 ==="
echo "pkill -f 'nx serve'        # 殺所有 nx serve"
echo "pkill -f 'webpack'         # 殺所有 webpack"
echo "kill -9 <PID>              # 殺特定進程"
