require 'spec_helper'

describe "with a closing pattern, using matchit" do
  let(:filename) { 'test.rb' }

  before :each do
    vim.set 'expandtab'
    vim.set 'shiftwidth', 2
  end

  describe "strategy: delete" do
    before :each do
      vim.command('let g:deleft_remove_strategy = "delete"')
    end

    specify "removes a wrapping if-clause, leaving only the selected contents" do
      set_file_contents <<~EOF
        if one?
          puts "one"
        else
          puts "two"
        end
      EOF

      vim.search 'one'
      vim.command 'Deleft'
      vim.write

      expect_file_contents <<~EOF
        puts "one"
      EOF

      vim.command('undo')

      vim.search 'else'
      vim.command 'Deleft'
      vim.write

      expect_file_contents <<~EOF
        puts "two"
      EOF
    end
  end

  describe "strategy: spaces" do
    before :each do
      vim.command('let g:deleft_remove_strategy = "spaces"')
    end

    specify "removes a wrapping if-clause, leaving spaces around the contents" do
      set_file_contents <<~EOF
        if one?
          puts "one"
        else
          puts "two"
        end
      EOF

      vim.search 'one'
      vim.command 'Deleft'
      vim.write

      expect_file_contents <<~EOF
        puts "one"

        puts "two"
      EOF

      vim.command('undo')

      vim.search 'else'
      vim.command 'Deleft'
      vim.write

      expect_file_contents <<~EOF

        puts "one"

        puts "two"
      EOF
    end
  end
end
