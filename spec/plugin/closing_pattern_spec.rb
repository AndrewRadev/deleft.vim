require 'spec_helper'

describe "with a closing pattern" do
  let(:filename) { 'test.rb' }

  before :each do
    vim.set 'expandtab'
    vim.set 'shiftwidth', 2
  end

  # TODO (2017-03-01) How to handle the `else` in the middle?
  specify "removes a wrapping if-clause" do
    set_file_contents <<~EOF
      if one?
        puts "one"
      else
        puts "two"
      end
    EOF

    vim.command "let b:dh_closing_pattern = '^\\s*end\\>'"

    vim.search 'one'
    vim.command 'Deleft'
    vim.write

    expect_file_contents <<~EOF
      puts "one"
      else
      puts "two"
    EOF
  end
end
