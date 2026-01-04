# square-motions.nvim
Add ] (next) and [ (previous) keymaps.

Includes nvim-treesitter-textobjects

Other plugins add start and end keymaps too, but I like just next/previous.

## Installation

**[Lazy.nvim](https://github.com/folke/lazy.nvim)**

```lua
{
  "caspersg/square-motions.nvim",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter" },
    { "nvim-treesitter/nvim-treesitter-textobjects" },
  },
  config = function()
    require("square-motions").setup({})
  end,
}

```


## examples

`]b` next buffer

`[ia` previous inner assignment

## Keymaps

] - next prefix

[ - previous prefix

q - quickfix

b - buffer

d - diagnostic

t - tab

l - fold

w - window

c - change

n - indent

j - jump

### textobjects

]i - inner prefix

]a - around prefix

a - assignment

R - assignment RHS

L - assignment LHS

A - attribute

k - block

c - call

C - class

o - comment

n - conditional

e - frame

f - function

l - loop

N - number

P - parameter

g - regex

r - return

O - scopename

S - statement

## Similar plugins

- [vim-unimpaired](https://github.com/tpope/vim-unimpaired)
- [mini.bracketed](https://github.com/echasnovski/mini.bracketed)

