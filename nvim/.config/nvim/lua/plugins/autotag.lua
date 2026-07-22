local ok, mod = pcall(require, "nvim-ts-autotag")
if not ok then return end
mod.setup()
