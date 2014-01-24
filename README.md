# Tyccl

tyccl(同义词词林 哈工大扩展版) is a  ruby gem that provides friendly functions to analyse similarity between Chinese Words.

all of Tyccl`s source files using charset: UTF-8

## Installation

Add this line to your application's Gemfile:

    gem 'tyccl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tyccl

## Usage
 
simple example:

```ruby

	require 'tyccl'
	tyc = Tyccl.instance  # singleton class
 
  # Given wordA(string) and wordB(string). 
  # Returns a Struct Result_t which contains idA, idB, and shortest semantic distance(int) between wordA and wordB. 

  	result = tyc.dist("西红柿","黄瓜") 
	  	puts result.value
	  	puts result.x_id
	  	puts result.y_id

  # Given wordA(string) and wordB(string).
  # Returns a Struct Result_t which contains the most similar Pairs wordA`s ID and wordB`s ID, and similarity(float) between idA and idB.
  	result = tyc.sim("西红柿","黄瓜")
	  	puts result.value
	  	puts result.x_id
	  	puts result.y_id

  # Given a word(string) and a level(int),level`s value range is [0,4],4 is default, value of level is more bigger, the similarity between returned words and the given word is more less.   
  # Returns a two dimensional array that contains the parameter Word`s similar words which divided by different ID that the word matchs.
  # If the word has no similar, nil is returned.

	m = tyc.get_similar("人")  
	puts m
	#[	["人", "士", "人物", "人士", "人氏", "人选"],
 	#	["成年人", "壮年人", "大人", "人", "丁", "壮丁", "佬", "中年人"],
 	#	["身体", "人"],
 	#	["人格", "人品", "人头", "人", "品质", "质地", "格调", "灵魂", "为人"],
 	#	["人数", "人头", "人口", "人", "口", "丁", "家口", "食指", "总人口"]	]

```
see more methods in tyccl/doc/index.html and more example in [test](https://github.com/JoeWoo/tyccl/blob/master/test/test_tyccl.rb)

## Contributing

1. Fork it ( http://github.com/JoeWoo/tyccl/fork )
2. Create your feature branch (`git checkout -b fork-new`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin fork-new`)
5. Create new Pull Request
>>>>>>> master
