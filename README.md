# DeadCodeTerminator

![ci](https://github.com/razum2um/dead_code_terminator/actions/workflows/main.yml/badge.svg)
[![gem](https://badge.fury.io/rb/dead_code_terminator.svg)](https://rubygems.org/gems/dead_code_terminator)
[![codecov](https://codecov.io/gh/razum2um/dead_code_terminator/branch/master/graph/badge.svg)](https://app.codecov.io/gh/razum2um/dead_code_terminator)

This acts like [webpack's DefinePlugin](https://webpack.js.org/plugins/define-plugin/) with minification pass. It allows to eliminate dead code statically, which can be required by regulations.

```ruby
value = if ENV['FLAG']
  :then_branch
else
  value2 = unless ENV['PRODUCTION']
    :then_branch
  else
    ENV['RUNTIME'] ? :else1 : :else2
  end
end
```

```ruby
# returns a valid ruby code string back with statically evaluated conditions
DeadCodeTerminator.strip(string, env: { "PRODUCTION" => true, "FLAG" => false })
```

```ruby
value = 


  value2 = 


    ENV['RUNTIME'] ? :else1 : :else2

 
```

Note: it keeps *precise* code locations (including whitespaces and line-breaks).
So if you have hotfix patches from upstream - they'll be applied without conflicts.
Backtrace line numbers are also preserved and can point to original code.

Other examples can be found in [specs](https://github.com/razum2um/dead_code_terminator/blob/master/spec/dead_code_terminator_spec.rb)

## TODO

- builtin file tree processing
## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
