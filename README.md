![RestClient demo](https://github.com/AndrewRadev/deleft.vim/raw/4074f409c113e59f2dee43e7b8b8615c4013f54e/demo/demo_restclient.gif)

[![Build Status](https://secure.travis-ci.org/AndrewRadev/deleft.vim.png?branch=master)](http://travis-ci.org/AndrewRadev/deleft.vim)

## Usage

This plugin allows you to delete wrapping if-clauses, try-catch blocks, and similar constructs. For example:

``` html
<div class="container">
  <a href="#">Something</a>
</div>
```

Executing the `:Deleft` command or using the provided `dh` mapping on the container div results in just:

``` html
<a href="#">Something</a>
```

So, the mapping/command deletes the opening and closing HTML tag and shifts the code to the left (hence the name "deleft", from "delete left").

Note that `dh` is a built-in mapping, but it's a synonym to `x`, so I'm okay with overwriting it. Set `g:deleft_mapping` to `""` (or whatever else you like) to avoid this.

Here's some more examples:

![HAML Containers demo](https://github.com/AndrewRadev/deleft.vim/raw/4074f409c113e59f2dee43e7b8b8615c4013f54e/demo/demo_containers.gif)
![Coffeescript callbacks demo](https://github.com/AndrewRadev/deleft.vim/raw/4074f409c113e59f2dee43e7b8b8615c4013f54e/demo/demo_callbacks.gif)
![Rails controller demo](https://github.com/AndrewRadev/deleft.vim/raw/4074f409c113e59f2dee43e7b8b8615c4013f54e/demo/demo_move_down.gif)

The plugin attempts to use the extended match definitions from `matchit`. In ruby, for instance, the matchit.vim (built-in) plugin lets you jump between any related `if`/`elsif`/`else`/`end` lines:

``` ruby
if one?
  two
elsif two?
  three
else
  four
end
```

Delefting the if-clause will also remove all other else-like lines, anything that the matchit plugin jumps to, as long as it's at the same level of indent, leaving you with just this:

``` ruby
two
three
four
```

If you'd like to handle the "contents" of the code blocks differently, you can decide this using the "remove strategy".

### Remove strategies

By default, the plugin deletes the "wrapping" if-clauses and else-clauses and such, leaving all the code inside intact, as-is. You might want to do something different, though. You can change this by changing the setting `g:deleft_remove_strategy`. By default, its value is "none".

For instance, changing the value to "comment" results in the "inactive" clause being commented out (as long as you have a supported commenting plugin). In this example:

``` ruby
if true
  puts "OK!"
else
  puts "There's something wrong here!"
end
```

With the cursor on `if true` and remove strategy set to "delete", delefting results in:

``` ruby
puts "OK!"
# puts "There's something wrong here!"
```

But, with the cursor on `else`, the results is:

``` ruby
# puts "OK!"
puts "There's something wrong here!"
```

You can read the documentation on `g:deleft_remove_strategy` for the full list of strategies and supported comment plugins.

### Non-matchit ("simple") delefting

If you don't have matchit activated, for some reason, or you're using a filetype that doesn't have matchit definitions, the plugin will just attempt to match the indent of the line you're deleting and the next line with the same indent. Or, in an indent-based language, it would delete the current line and deindent everything "underneath".

So, if you're writing python, which doesn't seem to have matchit definitions at the time of writing, you can still delete, say, a wrapping if-clause with deleft. Do consider adding your own matchit support, though, as described in `:help matchit-newlang`.

In order to determine which languages are indent-based, the plugin just maintains a list of them. If you'd like to add your own to the list, you can add it to `g:deleft_indent_based_filetypes`.

## Contributing

Pull requests are welcome, but take a look at [CONTRIBUTING.md](https://github.com/AndrewRadev/deleft.vim/blob/master/CONTRIBUTING.md) first for some guidelines.
