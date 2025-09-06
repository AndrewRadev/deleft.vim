require 'spec_helper'

describe "indent-based languages, not using matchit" do
  let(:filename) { 'test.yaml' }

  specify "Removes a wrapping object" do
    set_file_contents <<~EOF
      foo:
        bar:
          baz: "test"
    EOF

    vim.search 'bar'
    vim.command 'Deleft'
    vim.write

    expect_file_contents <<~EOF
      foo:
        baz: "test"
    EOF
  end

  specify "Removes a wrapping object with a following unindent" do
    set_file_contents <<~EOF
      foo:
        bar:
          baz: "one"
        quux:
          baz: "two"
    EOF

    vim.search 'bar'
    vim.command 'Deleft'
    vim.write

    expect_file_contents <<~EOF
      foo:
        baz: "one"
        quux:
          baz: "two"
    EOF
  end
end
