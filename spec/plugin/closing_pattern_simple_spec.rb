require 'spec_helper'

describe "with a closing pattern, not using matchit" do
  let(:filename) { 'test.rb' }

  def setup_filetype
    vim.set 'expandtab'
    vim.set 'shiftwidth', 2
    vim.command 'unlet b:match_words'
  end

  specify "removes a wrapping if-clause, leaving the `else`" do
    set_file_contents <<~EOF
      if one?
        puts "one"
      else
        puts "two"
      end
    EOF

    setup_filetype
    vim.command "let b:deleft_closing_pattern = '^\\s*end\\>'"

    vim.search 'one'
    vim.command 'Deleft'
    vim.write

    expect_file_contents <<~EOF
      puts "one"
      else
      puts "two"
    EOF
  end

  specify "removes a wrapping if-clause, leaving the `end`" do
    set_file_contents <<~EOF
      if one?
        puts "one"
      else
        puts "two"
      end
    EOF

    setup_filetype
    vim.command "let b:deleft_closing_pattern = '^\\s*else\\>'"

    vim.search 'one'
    vim.command 'Deleft'
    vim.write

    expect_file_contents <<~EOF
      puts "one"
        puts "two"
      end
    EOF
  end

  specify "removes a wrapping else-clause" do
    set_file_contents <<~EOF
      if one?
        puts "one"
      else
        puts "two"
      end
    EOF

    setup_filetype

    vim.search 'else'
    vim.command 'Deleft'
    vim.write

    expect_file_contents <<~EOF
      if one?
        puts "one"
      puts "two"
    EOF
  end
end
