require 'spec_helper'

describe "indent-based languages, using matchit" do
  let(:filename) { 'test.py' }

  def setup_filetype
    vim.command("let b:match_words = '\\<if\\>:\\<else\\>'")
    vim.set 'shiftwidth', 4
  end

  describe "strategy: delete" do
    around :each do |example|
      vim.command('let g:deleft_remove_strategy = "delete"')
      example.run
      vim.command('let g:deleft_remove_strategy = "none"')
    end

    specify "Removes a wrapping if-clause" do
      set_file_contents <<~EOF
        if one:
            print("foo")
        else:
            print("bar")
      EOF

      setup_filetype

      vim.search 'one'
      vim.command 'Deleft'
      vim.write

      expect_file_contents <<~EOF
        print("foo")
      EOF

      vim.command 'undo'

      vim.search 'else'
      vim.command 'Deleft'
      vim.write

      expect_file_contents <<~EOF
        print("bar")
      EOF
    end
  end

  describe "strategy: spaces" do
    around :each do |example|
      vim.command('let g:deleft_remove_strategy = "spaces"')
      example.run
      vim.command('let g:deleft_remove_strategy = "none"')
    end

    specify "Removes a wrapping if-clause" do
      set_file_contents <<~EOF
        if one:
            print("foo")
        else:
            print("bar")
      EOF

      setup_filetype

      vim.search 'one'
      vim.command 'Deleft'
      vim.write

      expect_file_contents <<~EOF
        print("foo")

        print("bar")

      EOF

      vim.command 'undo'

      vim.search 'else'
      vim.command 'Deleft'
      vim.write

      expect_file_contents <<~EOF

        print("foo")

        print("bar")
      EOF
    end
  end
end
