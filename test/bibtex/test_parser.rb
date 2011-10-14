require 'helper.rb'

module BibTeX
  class ParserTest < MiniTest::Spec
    
    describe 'given a set of valid @entries' do
      before do
        @bib = Parser.new(:debug => false).parse(File.read(Test.fixtures(:entry)))
      end
      
      it 'returns a Bibliography instance' do
        assert @bib
        refute @bib.empty?
      end
        
      it 'parses all entries' do
        assert_equal 3, @bib.length
      end
      
      it 'parses the key values' do
        assert_equal %w{ key:0 key:1 foo }, @bib.map(&:key)
      end

      it 'should parse the entry types' do
        assert_equal [:book, :article, :article], @bib.map(&:type)
      end
      
      it 'should parse all values correctly' do
        assert_equal 'Poe, Edgar A.', @bib[:'key:0'].author.to_s
        assert_equal 'Hawthorne, Nathaniel', @bib[:'key:1'].author.to_s
        
        assert_equal '2003', @bib[:'key:0'].year
        assert_equal '2001', @bib[:'key:1'].year

        assert_equal 'American Library', @bib[:'key:0'].publisher
        assert_equal 'American Library', @bib[:'key:1'].publisher
        
        assert_equal %q[Selected \emph{Poetry} and `Tales'], @bib[:'key:0'].title
        assert_equal 'Tales and Sketches', @bib[:'key:1'].title
      end     
    end
    
		describe 'key parsing' do
		  it 'handles whitespace in keys' do
        input = "@Misc{George Martin06,title = {FEAST FOR CROWS}}"
        bib = Parser.new(:debug => false, :strict => false).parse(input)
        assert_equal "George Martin06", bib.first.key
        assert bib[:"George Martin06"]
      end
    end
		
		describe 'backslashes and escape sequences' do
			
			it 'leaves backslashes intact' do
				Parser.new.parse(%q(@misc{key, title = "a backslash: \"}))[0].title.must_be :==, 'a backslash: \\'
			end
			
			it 'parses LaTeX escaped quotes {"}' do
				Parser.new.parse(%q(@misc{key, title = "{"}"}))[0].title.must_be :==, '{"}'
			end
			
		end
		
    describe 'given a set of explicit and implicit comments' do
      before do
        @bib = Parser.new(:debug => false, :include => [:meta_content]).parse(File.read(Test.fixtures(:comment)))
      end
      
      it 'should parses all @comments' do
        assert_equal 2, @bib.comments.length
      end

      it 'should parses all meta content' do
        assert_equal 3, @bib.meta_contents.length
      end
      
      it 'should parse @comment content as string' do
        assert_equal ' A comment can contain pretty much anything ', @bib.comments[0].content
        assert_equal %Q[\n@string{ foo = "bar" }\n\n@string{ bar = "foo" }\n], @bib.comments[1].content
      end 
    end
    
    describe 'given a set of @preambles' do
      before do
        @bib = Parser.new(:debug => false).parse(File.read(Test.fixtures(:preamble)))
      end
      
      it 'should parse all @preambles' do
        assert_equal 3, @bib.preambles.length
      end
      
      it 'should parse all contents' do
        assert_equal 'This bibliography was created \\today', @bib.preambles[0].value.to_s
        assert_equal 'Bib\\TeX', @bib.preambles[1].value.to_s
        assert_equal '"Maintained by " # maintainer', @bib.preambles[2].value.to_s
      end
    end
    
    describe 'given an entry containing a multi-line literals' do
      before do
        @braces = %Q[@TechReport{key,\n  author = {Donald,\n     Duck}\n}]
        @string = %Q[@TechReport{key,\n  author = "Donald,\n     Duck"\n}]
      end
      
      it 'should parse string literals' do
        refute_nil Parser.new.parse(@string)[:key]
      end

      it 'should parse braced literals' do
        refute_nil Parser.new.parse(@braces)[:key]
      end

    end
    
  end
end
