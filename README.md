# instant-bench-nvim

Benchmark selected text

```vim
" Dependency
Plug 'nvim-lua/plenary.nvim'
" Plugin
Plug 'instant-bench/instant-bench-nvim'
```

## Setup

```vim
lua << EOF
require("instant-bench").setup {
  endpoint = "http://localhost:4001"
}
EOF
```

The endpoint should be the server URL running [instant-code-2bench](https://github.com/Instant-Bench/instant-code-2bench).
