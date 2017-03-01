require 'spec_helper'

describe "non-indent-based languages" do
  let(:filename) { 'test.rb' }

  before :each do
    vim.set 'expandtab'
    vim.set 'shiftwidth', 2
  end

  specify "removes a wrapping if-clause" do
    set_file_contents <<~EOF
      if one?
        if two?
          if three?
            puts "OK"
          end
        end
      end
    EOF

    vim.search 'two'
    vim.command 'Deleft'
    vim.write

    expect_file_contents <<~EOF
      if one?
        if three?
          puts "OK"
        end
      end
    EOF
  end
end
