# coding: utf-8
require 'rake'
require 'rake/testtask'
require 'test/unit'
require File.expand_path('../../lib/tyccl', __FILE__)


$tyc=Tyccl.instance

class TycclTest < Test::Unit::TestCase

  def test_instance
    assert_equal 17809,
        $tyc.get_id_sum
    assert_equal 77457,
    	$tyc.get_index_sum
  end

  def test_get_words_by_id
  	assert_equal ["人","士","人物","人士","人氏","人选"],
  		$tyc.get_words_by_id("Aa01A01=")
  	assert_equal nil,
  		$tyc.get_words_by_id("dfdf")

  end
  
  def test_get_ids_by_wildcard
  	assert_equal 9,
  		$tyc.get_ids_by_wildcard("Aa01A...").size
  	assert_equal 32,
  		$tyc.get_ids_by_wildcard("Aa**A...").size
  end

  def test_get_ids_by_word
  	assert_equal nil,
  		$tyc.get_ids_by_word("屌丝")
  	assert_equal 1,
  		$tyc.get_ids_by_word("桅顶").size
  	assert_equal 7,
  		$tyc.get_ids_by_word("底").size
  end

  def test_has_same
  	assert_equal true,
  		$tyc.has_same?("人")
  	assert_equal false,
  		$tyc.has_same?("顺民")
  	assert_equal false,
  		$tyc.has_same?("众学生")
  end

  def test_has_equal
  	assert_equal true,
  		$tyc.has_equal?("良民")
  	assert_equal false,
  		$tyc.has_equal?("众学生")
  	assert_equal false,
  		$tyc.has_equal?("人")
  end

  def test_has_single
  	assert_equal false,
  		$tyc.has_single?("良民")
  	assert_equal true,
  		$tyc.has_single?("众学生")
  	assert_equal false,
  		$tyc.has_single?("人")
  end

  def test_get_same
  	m=$tyc.get_same("人")
  	
  	assert_equal nil,
  		$tyc.get_same("顺民")
  	assert_equal nil,
  		$tyc.get_same("众学生")
  	assert_equal 5,
  		m.size
  	assert_equal 6,
  		m[0].size
  	assert_equal 8,
  		m[1].size
  	assert_equal 2,
  		m[2].size
  	assert_equal 9,
  		m[3].size
  	assert_equal 9,
  		m[4].size
  	
  end

  def test_get_equal
  	assert_equal nil,
  		$tyc.get_equal("人")
  	assert_equal nil,
  		$tyc.get_equal("众学生")
  	assert_equal 1,
  		$tyc.get_equal("流民").size
  	assert_equal 9,
  		$tyc.get_equal("流民")[0].size
  end

  def test_get_similar
   	assert_equal [	["人", "士", "人物", "人士", "人氏", "人选"],
 					["成年人", "壮年人", "大人", "人", "丁", "壮丁", "佬", "中年人"],
 					["身体", "人"],
 					["人格", "人品", "人头", "人", "品质", "质地", "格调", "灵魂", "为人"],
 					["人数", "人头", "人口", "人", "口", "丁", "家口", "食指", "总人口"]	],
  		$tyc.get_similar("人")
  end

# dist ranges [0,10]; 
# if dist<7 then we believe that the two words are related 
  def test_dist  
  	assert_equal Result_t.new(0,"Aa01A01=","Aa01A01="),
  		$tyc.dist("人","士")
  	assert_equal Result_t.new(2,"Bh06A32=","Bh06A34="),
  		$tyc.dist("西红柿","黄瓜")
  	assert_equal Result_t.new(4,"Aa01A05=","Aa01B03#"),
  		$tyc.dist("匹夫","良民")
  	assert_equal Result_t.new(6,"Bh07A14=","Bh06A32="),
  		$tyc.dist("苹果","西红柿")
  	assert_equal Result_t.new(8,"Aa01B02=","Ab01B10="),
  		$tyc.dist("群众","村姑")
  	assert_equal Result_t.new(10,"Aa01A01=","Kd04C01="),
  		$tyc.dist("人","哟")
  end

  def test_sim
	result=[	Result_t.new(1.0,"Aa01B01=","Aa01B01="),
				Result_t.new(0.95766,"Aa01B01=","Aa01B02="),
				Result_t.new(0.71825,"Aa01B01=","Aa01B03#"),
				Result_t.new(0.48013,"Aa01B01=","Aa01C07#"),
				Result_t.new(0.40396,"Aa01B01=","Ab02B01="),
				Result_t.new(0.39028,"Aa01B01=","Ad01A02="),
				Result_t.new(0.21692,"Aa01B01=","Aa03A05="),
				Result_t.new(0.20361,"Aa01B01=","Ah01A01="),
				Result_t.new(0.08112,"Aa01B01=","Ak03A03#"),
				Result_t.new(0.04007,"Aa01B01=","Al05B01=") 	]

  	words=["国民","群众","良民","党群","成年人","市民","同志","亲属","志愿者","先锋"]
  	i=0
  	words.each{  |word|
  		assert_equal result[i],
  			$tyc.sim("人民",word)
  		i+=1
  	}
  end

end

