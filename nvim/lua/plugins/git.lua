return {
  -- 1. 增強內建的 gitsigns (實現行末顯示作者資訊，類似 GitLens)
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true, -- 啟動虛擬文字顯示當前行的 Git Blame
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 顯示在行末 (End of Line)
        delay = 500, -- 游標停下 0.5 秒後顯示
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "   <author> • <author_time:%Y-%m-%d> • <summary>",
    },
  },

  -- 2. 安裝 Blame.nvim (實現左側完整 Blame 資訊列)
  {
    "FabijanZulj/blame.nvim",
    cmd = "BlameToggle",
    keys = {
      { "<leader>gb", "<cmd>BlameToggle<cr>", desc = "Git Blame (Full Column)" },
    },
    opts = {
      date_format = "%Y-%m-%d",
    },
  },

  -- 3. 安裝 Diffview.nvim (實現強大的檔案歷史與 Diff 對比視圖)
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Git File History (Current File)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Git Project History" },
    },
    opts = {
      enhanced_diff_hl = true,
    },
  },
}
