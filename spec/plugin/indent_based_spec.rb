require 'spec_helper'

describe "indent-based languages" do
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
end
