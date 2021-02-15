require 'spec_helper'

describe "filetype: rust" do
  let(:filename) { 'test.rs' }

  describe "strategy: delete" do
    before :each do
      vim.command('let g:deleft_remove_strategy = "delete"')
    end

    specify "working on if-clauses" do
      vim.set 'shiftwidth', 2

      set_file_contents <<~EOF
        // Example
        if 2 < 1 {
          println!("ok");
        } else if 2 == 1 { // test
          println!("kinda weird");
        } else {
          println!("weird");
        }
      EOF

      vim.search 'if'
      vim.command 'Deleft'
      vim.write

      expect_file_contents <<~EOF
        // Example
        println!("ok");
      EOF
    end

    specify "empty blocks" do
      vim.set 'shiftwidth', 2

      set_file_contents <<~EOF
        // Example
        if 2 < 1 {
        } else {
          println!("kinda weird");
        }
      EOF

      vim.search 'if'
      vim.command 'Deleft'
      vim.write

      expect_file_contents <<~EOF
        // Example
      EOF

      vim.command('undo')
      vim.search 'else'
      vim.command 'Deleft'
      vim.write

      expect_file_contents <<~EOF
        // Example
        println!("kinda weird");
      EOF
    end
  end

  describe "strategy: spaces" do
    before :each do
      vim.command('let g:deleft_remove_strategy = "spaces"')
    end

    specify "working on if-clauses" do
      vim.set 'shiftwidth', 2

      set_file_contents <<~EOF
        // Example
        if 2 < 1 {
          println!("ok");
        } else if 2 == 1 { // test
          println!("kinda weird");
        } else {
          println!("weird");
        }
      EOF

      vim.search 'if'
      vim.command 'Deleft'
      vim.write

      expect_file_contents <<~EOF
        // Example
        println!("ok");

        println!("kinda weird");

        println!("weird");
      EOF
    end

    specify "empty blocks" do
      vim.set 'shiftwidth', 2

      set_file_contents <<~EOF
        // Example
        if 2 < 1 {
        } else {
          println!("kinda weird");
        }
      EOF

      vim.search 'if'
      vim.command 'Deleft'
      vim.write

      expect_file_contents <<~EOF
        // Example

        println!("kinda weird");
      EOF
    end
  end
end
