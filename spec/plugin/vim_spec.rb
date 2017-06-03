require 'spec_helper'

describe "filetype: vim" do
  let(:filename) { 'test.vim' }

  specify "working on functions (ignore `return`s)" do
    vim.set 'shiftwidth', 2

    set_file_contents <<~EOF
      " Example
      function! Example()
        if 2 < 1
          return "ok"
        else
          return "not ok"
        endif
      endfunction
    EOF

    vim.search 'function!'
    vim.command 'Deleft'
    vim.write

    expect_file_contents <<~EOF
      " Example
      if 2 < 1
        return "ok"
      else
        return "not ok"
      endif
    EOF
  end
end
