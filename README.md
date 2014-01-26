# Tyccl

tyccl(同义词词林 哈工大扩展版) is a  ruby gem that provides friendly functions to analyse similarity between Chinese Words.

all of Tyccl`s source files using charset: UTF-8  
Finding algorithm using Tire and Hash, Time complexity O(m) m<=5,   Space complexity O(n), n is proportional to the records of Cilin.  
Cilin.txt(892.6KB).   

## Installation

Add this line to your application's Gemfile:

    gem 'tyccl'  
    gem 'algorithms'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tyccl  
    $ gem install algorithms  

## Usage
 
simple example:

```ruby
  
  # Result_t = Struct.new(:value,:x_id,:y_id)
  # this struct is used to return analysing result
  # * field 'value' store the analysing value
  # * field 'x_id' 'y_id' store the ID of word X and Y 
	
  require 'tyccl'
 
  # Given wordA(string) and wordB(string). 
  # Returns a Struct Result_t which contains idA, idB, and shortest semantic distance(int) between wordA and wordB. 

  	result = Tyccl.dist("西红柿","黄瓜") 
	  	puts result.value
	  	puts result.x_id
	  	puts result.y_id

  # Given wordA(string) and wordB(string).
  # Returns a Struct Result_t which contains the most similar Pairs wordA`s ID and wordB`s ID, and similarity(float) between idA and idB.
  	result = Tyccl.sim("西红柿","黄瓜")
	  	puts result.value
	  	puts result.x_id
	  	puts result.y_id

  # Given a word(string) and a level(int),level`s value range is [0,4],4 is default, value of level is more bigger, the similarity between returned words and the given word is more less.   
  # Returns a two dimensional array that contains the parameter Word`s similar words which divided by different ID that the word matchs.
  # If the word has no similar, nil is returned.

	m = Tyccl.get_similar("人")  
	puts m
	#[	["人", "士", "人物", "人士", "人氏", "人选"],
 	#	["成年人", "壮年人", "大人", "人", "丁", "壮丁", "佬", "中年人"],
 	#	["身体", "人"],
 	#	["人格", "人品", "人头", "人", "品质", "质地", "格调", "灵魂", "为人"],
 	#	["人数", "人头", "人口", "人", "口", "丁", "家口", "食指", "总人口"]	]

```

download and see more methods in [api doc](https://github.com/JoeWoo/tyccl/blob/master/doc/index.html) and more examples in [test](https://github.com/JoeWoo/tyccl/blob/master/test/test_tyccl.rb).

## Contributing

1. Fork it ( http://github.com/JoeWoo/tyccl/fork )
2. Create your feature branch (`git checkout -b fork-new`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin fork-new`)
5. Create new Pull Request
