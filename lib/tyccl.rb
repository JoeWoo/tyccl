require "tyccl/version"
require "algorithms"
require "yaml"
require "singleton"
require "bigdecimal"
require "bigdecimal/math"

include BigMath

Pairs = Struct.new(:value,:X_id,:Y_id)

class Tyccl
  include Singleton

  def initialize()
    #read the cilin.txt to codes[] and items[]
    codes=[]
    items=[]
    @codesIndex = Hash.new
    f = File.new('./cilin.txt')
    i=0
    f.each { |line|
      line.force_encoding('utf-8')
      m=line.split(" ")
      codes << m[0]
      @codesIndex[m[0]] = i
      i += 1
      word = Array.new
      m[1..-1].each{ |term|
        word << term
      }
      items << word
    }
    #init Trie of cilin.txt
    @codesTrie = Containers::Trie.new
    i=0
    codes.each{ |key|
      @codesTrie[key]=items[i]
      i+=1
    }
    #init index of cilin.txt
    @index = YAML.load(File.open("./Inverted.yaml"))
  end

  def get_atom_by_id(code)
    @codesTrie[code]
  end

  def get_ids_by_grep(grepX)
    @codesTrie.wildcard(grepX)
  end

  def get_id_by_word(word)
    @index[word]
  end

  def has_same?(word)
    codes = get_id_by_word(word)
    i=0
    flag=false
    while i < codes.size && flag==false  do
      if code[-1]=="="
        flag=true
      else
        flag=false
      end
    end
    flag
  end

  def has_equal?(word)
    codes = get_id_by_word(word)
    i=0
    flag=false
    while i < codes.size && flag==false  do
      if code[-1]=="#"
        flag=true
      else
        flag=false
      end
    end
    flag
  end

  def get_same(word)
    if has_same?(word)
      same_words=[]
      codes = get_id_by_word(word)
      codes.each{ |code|
        if code[-1]=="="
         same_words << get_atom_by_id(code)
        end
      }
      return same_words
    end
    nil
  end

  def get_equal(word)
    if has_equal?(word)
      equal_words=[]
      codes = get_id_by_word(word)
      codes.each{ |code|
        if code[-1]=="#"
          equal_words << get_atom_by_id(code)
        end
      }
      return equal_words
    end
    nil
  end
  # level 4，3，2，1，0层级 对应同义词词林划分的A，a，01，A，01=五个层次
  def get_similar(word,level)
    codes = get_id_by_word(word)
    similar=[]
    codes.each{ |code|
      mini_similar=[]
      findstring = gen_findstring(code, level)
      similar_codes=@codesTrie.wildcard(findstring)
      similar_codes.each{|item|
        get_atom_by_id(item).each{|term|
          mini_similar << term
        }
      }
      similar << mini_similar
    }
    return similar
  end

  def gen_findstring(code,level)
    frame = cut_code(code)
    level.upto(4){|i|
      frame[i].each{|char|
        char = "."
      }
    }
    combine_code(frame)
  end

  def cut_code(code)
    frame=[code[0],code[1],code[2..3],code[4],code[5..7]]
  end

  def combine_code(frame)
    m=""
    frame.each{|seg|
      m << seg
    }
    return m
  end

  def compare_code(codeA,codeB)
    frameA=cut_code(codeA)
    frameB=cut_code(codeB)
    0.upto(frameA.length-1){ |i|
      if frameA[i].eql?(frameB[i]) == false
        return i
      end
    }
    return -100
  end

  def dist(wordA,wordB)
    ld=0
    alpha=0.3
    shortest_Pair = Pairs.new(10,"","")
    codeAs = get_id_by_word(wordA)
    codeBs = get_id_by_word(wordB)

    codeAs.each{ |codeA|
      codeBs.each{ |codeB|
        n = compare_code(codeA,codeB)+1
        if n >= 0
          distance = ( ( ( (n-5).abs * (4-n)) / 10 ) + 0.1 ) / 2.1 + ld*alpha
        else
          distance = 0
        end

        if distance < shortest_Pair.dist
          shortest_Pair.value = distance
          shortest_Pair.X_id = codeA
          shortest_Pair.Y_id = codeB
        end
      }
    }
    return shortest_Pair
  end

  def sim(wordA,wordB)
    factor=[0.1,0.65,0.8,0.9,0.96,1,0.5]#0,1,2,3,4,-100各层参数
    shortest_Pair = Pairs.new(0,"","")
    codeAs = get_id_by_word(wordA)
    codeBs = get_id_by_word(wordB)

    codeAs.each{ |codeA|
      codeBs.each{ |codeB|
        n = compare_code(codeA,codeB)
        str = codeA.clone
        if n > 0
          gen_findstring(str,n)
          node_num = @codesTrie.wildcard(gen).size
          k = (@codesIndex[codeA]-@codesIndex[codeB]).abs + 1
          _sim = factor[n]*BigMath.cos(node_num*PI/180,10).abs*((node_num-k+1)/node_num)
        elsif n==0
          _sim = 0.1
        else
          if codeA[-1] == "="
            _sim = 1
          elsif codeA[-1] == "#"
            _sim = 0.5
          elsif codeA[-1] == "@"
            _sim = 1
          end
        end

        if distance < shortest_Pair.dist
          shortest_Pair.value = _sim
          shortest_Pair.X_id = codeA
          shortest_Pair.Y_id = codeB
        end
      }
    }
    return shortest_Pair
  end

end
