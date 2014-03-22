require "minitest/autorun"
require "./tree-generator.rb"

class TestMeme < Minitest::Unit::TestCase

  def setup
    @source = "* foo
    * bar
    * baz
    * lol
        * rofl
        * omfg
    * test
    * moep
* test
* another
* list
  * muppy
    * duppy
    * huppy"
  end

  def test_utf8
    expected = "•
├── foo
│   ├── bar
│   ├── baz
│   ├── lol
│   │   ├── rofl
│   │   └── omfg
│   ├── test
│   └── moep
├── test
├── another
└── list
    └── muppy
        ├── duppy
        └── huppy"

    assert_equal expected, Kramdown::Document.new(@source, :symbols => :utf8).to_tree
  end

    def test_ascii
      expected = "o
|-- foo
|   |-- bar
|   |-- baz
|   |-- lol
|   |   |-- rofl
|   |   `-- omfg
|   |-- test
|   `-- moep
|-- test
|-- another
`-- list
    `-- muppy
        |-- duppy
        `-- huppy"

    assert_equal expected, Kramdown::Document.new(@source, :symbols => :ascii).to_tree
  end
end
