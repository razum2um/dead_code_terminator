# DeadCodeTerminator

This acts like [webpack's DefinePlugin](https://webpack.js.org/plugins/define-plugin/) with minification pass. It allows to eliminate dead code statically, which can be required by regulations.

```ruby
if ENV['PRODUCTION']
    :then_branch
else
    :else_branch
end
```

```ruby
  
    :then_branch

        

```

Note: it keeps *precise* code locations (including whitespaces and line-breaks).
So if you have hotfix patches from upstream - they'll be applied without conflicts.

## TODO

- `unless`
- `x ? a : b`
- builtin file tree processing
## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
