require 'spec_helper'

describe "indent-based languages, not using matchit" do
  let(:filename) { 'test.py' }

  specify "Removes a wrapping if-clause" do
    set_file_contents <<~EOF
      if one:
          if two:
              if three:
                  pass
    EOF

    vim.search 'two'
    vim.command 'Deleft'
    vim.write

    expect_file_contents <<~EOF
      if one:
          if three:
              pass
    EOF
  end

  specify "Removes a wrapping if-clause with a following unindent" do
    set_file_contents <<~EOF
      if wrapping:
          if one:
              two
          if another:
              three
    EOF

    vim.search 'one'
    vim.command 'Deleft'
    vim.write

    expect_file_contents <<~EOF
      if wrapping:
          two
          if another:
              three
    EOF
  end
end
