# coding: utf-8

# = this gem is a tool for analysing similarity
# = between Chinese words. it based on <em>HIT Tongyici Cilin (Extended)<\em>(同义词词林())  
# 
# * learn more about Tongyici Cilin(同义词词林) http://vdisk.weibo.com/s/qGrIviGdExvx
#
# * Author::    Joe Woo  (https://github.com/JoeWoo)
# * License::   MIT
#

require File.expand_path("../tyccl/version", __FILE__)#:nodoc:all
require "algorithms"#:nodoc:all
require "yaml"#:nodoc:all
require "logger"#:nodoc:all


# this struct is used to return analysing result
# * field 'value' store the analysing value
# * field 'x_id' 'y_id' store the ID of word X and Y  
Result_t = Struct.new(:value,:x_id,:y_id)

# class Tyccl is a singleton class, no Tyccl.new() method instead of Tyccl.instance()
# to keep Tyccl object just only one. 
class Tyccl

  #--
  # Read the Cilin file to memory.
  # Format the data structure \#@IDsTire.
  # Index the hash \#@IDsIndex.
  #++
	#--
  #read the cilin.txt to ids[] and items[]
  #++
  @logger = Logger.new(STDOUT)
  @logger.level = Logger::WARN
  codes=[]
  items=[]
  @IDsIndex = Hash.new
  f = File.new(File.expand_path("../cilin.txt", __FILE__))
  i=0
  f.each { |line|
    line.force_encoding('utf-8')
    m=line.split(" ")
    codes << m[0]
    @IDsIndex[m[0]] = i
    i += 1
    word = Array.new
    m[1..-1].each{ |term|
      word << term
    }
    items << word
  }
  #--
  #init Trie of cilin.txt
  #++
  @IDsTrie = Containers::Trie.new
  i=0
  codes.each{ |key|
    @IDsTrie[key]=items[i]
    i+=1
  }
  #--
  #init index of cilin.txt
  #++
  @index = YAML::load(File.open(File.expand_path("../Inverted.yaml", __FILE__)))


 

  # Given id(string) such as:"Aa01A01=" "Aa01A03#"
  # Returns an array containing words(string) that match this id 
  # If no match is found, nil is returned.
  def self.get_words_by_id(id)
    @IDsTrie[id]
  end

  # Returns a sorted array containing IDs(string) that match the parameter Wildcard(string). 
  # The wildcard characters that match any character are ‘*’ and ‘.’ such as "Aa01A..=","Aa**A..."
  # If no match is found, an empty array is returned.
  def self.get_ids_by_wildcard(wildcard)
    @IDsTrie.wildcard(wildcard)
  end

  # Returns an array containing IDs(string) that the parameter Word(string) matchs.
  #
  # tips: the same word may have a few semantic meanings, so a word can match many IDs.
  def self.get_ids_by_word(word)
    m = @index[word]
  	if(m==nil)
  		@logger.error(word+" is an unlisted word!")
  		return nil
  	else
  		return m
  	end
  end

  # Given a word(string).
  # Test to see if the parameter Word has any synonym.
  # Returns true or false. 
  def self.has_same?(word)
    ids = get_ids_by_word(word)
    i=0
    flag=false
    while i < ids.size && flag==false  do
      if ids[i][-1]=="="
        flag=true
      else
        flag=false
      end
      i+=1
    end
    return flag
  end

  # Given a word(string).
  # Test to see if the parameter Word has any equivalent word.
  # Returns true or false.
  def self.has_equal?(word)
    ids = get_ids_by_word(word)
    i=0
    flag=false
    while i < ids.size && flag==false  do
      if ids[i][-1]=="#"
        flag=true
      else
        flag=false
      end
      i+=1
    end
    return flag
  end

  # Given a word(string).
  # Test to see if the parameter Word has any ID whose corresponding 
  # words list just has only one element. 
  # Returns true or false. 
  def self.has_single?(word)
  	ids = get_ids_by_word(word)
    i=0
    flag=false
    while i < ids.size && flag==false  do
      if ids[i][-1]=="@"
        flag=true
      else
        flag=false
      end
      i+=1
    end
    return flag
  end

  # Given a word(string). 
  # Returns a two dimensional array that contains the parameter Word`s 
  # synonym which divided by different ID that the word matchs.
  # If the word has no synonym, nil is returned. 
  def self.get_same(word)
    if has_same?(word)
      same_words=[]
      ids = get_ids_by_word(word)
      ids.each{ |code|
        if code[-1]=="="
         same_words << get_words_by_id(code)
        end
      }
      return same_words
    end
    return nil
  end

  # Given a word(string). 
  # Returns a two dimensional array that contains the parameter Word`s 
  # equivalent words which divided by different ID that the word matchs.
  # If the word has no synonym, nil is returned. 
  def self.get_equal(word)
    if has_equal?(word)
      equal_words=[]
      ids = get_ids_by_word(word)
      ids.each{ |code|
        if code[-1]=="#"
          equal_words << get_words_by_id(code)
        end
      }
      return equal_words
    end
    return nil
  end

  # Given a word(string) and a level(int),level`s value range is [0,4],
  # 4 is default, value of level is more bigger, the similarity between
  # returned words and the given word is more less.   
  # Returns a two dimensional array that contains the parameter Word`s 
  # similar words which divided by different ID that the word matchs.
  # If the word has no similar, nil is returned. 
  #
  # tips: level 0,1,2,3,4 correspond Cilin(同义词词林) ID`s different 
  # segment: A，a，01，A，01=. 
  def self.get_similar(word, level=4)
  	ids = get_ids_by_word(word)
    similar=[]
    ids.each{ |code|
      mini_similar=[]
      findstring = gen_findstring(code, level+1)
      similar_IDs=@IDsTrie.wildcard(findstring)
      similar_IDs.each{|item|
        get_words_by_id(item).each{|term|
          mini_similar << term
        }
      }
      similar << mini_similar
    }
    if similar.size > 0
    	return similar
    else
    	return nil
    end
  end

  # Given idA(string) and idB(string).
  # Returns semantic distance(int) between idA and idB, values in [0,10].
  def self.get_dist_by_id(idA, idB)
  	alpha=10.0/5
  	n = compare_id(idA,idB)
  	(alpha*(5-n)).round
  end

  # Given idA(string) and idB(string).
  # Returns similarity(float) between idA and idB, values in [0,1]. 
  def self.get_sim_by_id(idA, idB)
   	n = compare_id(idA,idB)
    str = idA.clone   
    if n==0
      _sim = factor[0]
    elsif n==5
      if idA[-1] == "="
        _sim = factor[5]
      elsif idA[-1] == "#"
        _sim = factor[6]
      elsif idA[-1] == "@"
        _sim = factor[5]
      end
  	elsif n < 5
  	  findstring=gen_findstring(str,n)
      node_num = @IDsTrie.wildcard(findstring).size
      k = (@IDsIndex[idA]-@IDsIndex[idB]).abs
      _sim = factor[n]*(Math.cos(node_num*Math::PI/180)).abs*((node_num-k+1)*1.0/node_num)
    end
    return _sim
  end 
  
  # Given wordA(string) and wordB(string).
  # Returns a Struct Result_t which contains idA, idB, and shortest 
  # semantic distance(int) between wordA and wordB.
  def self.dist(wordA, wordB)
    alpha=10.0/5
    shortest_Pair = Result_t.new(100,"","")
    idAs = get_ids_by_word(wordA)
    idBs = get_ids_by_word(wordB)

    idAs.each{ |idA|
      idBs.each{ |idB|
        n = compare_id(idA,idB)
          distance = (alpha*(5-n)).round
        if distance < shortest_Pair.value
          shortest_Pair.value = distance
          shortest_Pair.x_id = idA
          shortest_Pair.y_id = idB
        end
      }
    }
    return shortest_Pair
  end

  # Given wordA(string) and wordB(string).
  # Returns a Struct Result_t which contains the most similar Pairs 
  # wordA`s ID and wordB`s ID, and similarity(float) between idA and idB.
  def self.sim(wordA, wordB)
    factor=[0.02,0.65,0.8,0.9,0.96,1,0.5]#0,1,2,3,4,5各层参数
    longest_Pair = Result_t.new(-1,"","")
    idAs = get_ids_by_word(wordA)
    idBs = get_ids_by_word(wordB)

    idAs.each{ |idA|
      idBs.each{ |idB|
        n = compare_id(idA,idB)
        str = idA.clone   
        if n==0
          _sim = factor[0]
        elsif n==5
          if idA[-1] == "="
            _sim = factor[5]
          elsif idA[-1] == "#"
            _sim = factor[6]
          elsif idA[-1] == "@"
            _sim = factor[5]
          end
      	elsif n < 5
      	  findstring=gen_findstring(str,n)
          node_num = @IDsTrie.wildcard(findstring).size
          k = (@IDsIndex[idA]-@IDsIndex[idB]).abs
          _sim = factor[n]*(Math.cos(node_num*Math::PI/180)).abs*((node_num-k+1)*1.0/node_num)
        end
        
        if _sim > longest_Pair.value
          longest_Pair.value = _sim
          longest_Pair.x_id = idA
          longest_Pair.y_id = idB
        end
      }
    }
    longest_Pair.value = ("%1.5f" % longest_Pair.value).to_f
    return longest_Pair
  end

  # Given a word(string) and start_index(int),start_index`s value 
  # range is [0,4], corresponding Cilin(同义词词林) ID`s different 
  # segment: A，a，01，A，01=. 
  # Returns a string that is used '.' to explace every char from 
  # the start_index to the string`s end. 
  def self.gen_findstring(code, start_index)
    frame = cut_id(code)
    (start_index).upto(4){|i|
    	0.upto(frame[i].size-1){ |j|
    		frame[i][j]='.'
    	}
    }
    combine_id(frame)
  end

  # Given a id(string).
  # Returns an array that contains 5 strings which are ID`s 
  # diffrent segment, like: A，a，01，A，01= .
  def self.cut_id(id)
    frame=[id[0],id[1],id[2..3],id[4],id[5..7]]
    return frame
  end

  # the method #cut_id`s inverse process.
  def self.combine_id(frame)
    m=""
    frame.each{|seg|
      m << seg
    }
    return m
  end
  
  # Given idA(string) and idB(string).
  # Returns fisrt diffrent place of their segment, place vlaues in[0,4].
  # if they are the same , returns 5.
  def self.compare_id(idA, idB) 
    frameA=cut_id(idA)
    frameB=cut_id(idB)
    0.upto(frameA.length-1){ |i|
      if frameA[i].eql?(frameB[i]) == false
        return i
      end
    }
    return 5
  end

  # Returns the total number of different ID in Cilin. 
  def self.get_id_sum
  	@IDsIndex.size
  end

  # Returns the total number of different words in Cilin. 
  def self.get_index_sum
  	@index.size
  end

end