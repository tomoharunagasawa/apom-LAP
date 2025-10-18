module ReVIEW
	module BuilderOverride
		# chaprefb: 太字＋章番号とタイトル参照
		Compiler.definline :chaprefb
		def inline_chaprefb(s)
			title = inline_chapref(s)
			if @book.config['chapterlink']
			  "\\hyperref[chap:#{s}]{\\textbf{#{title}}}"
			else
			  inline_b(title)
			end
		  rescue KeyError
			error "unknown chapter: #{s}"
			nofunc_text("[UnknownChapter:#{s}]")
		end

		# titleb: 太字＋タイトル参照
		Compiler.definline :titleb
		def inline_titleb(id)
			title = inline_title(id)
			if @book.config['chapterlink']
			  "\\hyperref[chap:#{id}]{\\textbf{#{title}}}"
			else
			  inline_b(title)
			end
		rescue KeyError
			error "unknown chapter: #{id}"
			nofunc_text("[UnknownChapter:#{id}]")
		end		
		
		# wb: <w>＋<b>
		Compiler.definline :wb
		def inline_wb(word)
			inline_b(inline_w(word))
		end

		# wi: <w>＋<i>
		Compiler.definline :wi
		def inline_wi(word)
			inline_i(inline_w(word))
		end

		# idxb: <b>＋<idx>
		Compiler.definline :idxb
		def inline_idxb(word)
			inline_b(word) + index(word)
		end
		
		# idxi: <i>＋<idx>
		Compiler.definline :idxi
		def inline_idxi(word)
			inline_i(word) + index(word)
		end
		
		# widx: <w>＋<idx>
		Compiler.definline :widx
		def inline_widx(word)
			inline_idx(inline_w(word))
		end
	end
		
	class Builder
		prepend BuilderOverride
	end


	# module IndexBuilderOverride
	# 	Compiler.defblock :columnbox, 0..1
	# 	def columnbox(lines, behavior=nil)
	# 		# nil
	# 	end
	# end

	# class IndexBuilder
	# 	prepend IndexBuilderOverride
	# end

	# module HTMLBuilderOverride
	# 	Compiler.defblock :columnbox, 0..1
	# 	def columnbox(lines, behavior=nil)
	# 		# nil
	# 	end
	# end

	# class HTMLBuilder
	# 	prepend HTMLBuilderOverride
	# end

	module LATEXBuilderOverride
		# レイアウト調整のためにパラグラフメソッドをオーバーライドしておく
		def paragraph(lines)
			blank
			if @book.config['join_lines_by_lang']
			  puts join_lines_to_paragraph(lines)
			else
			  puts '\setlength{\parskip}{0.5zh}'
			  lines.each { |line| puts line }
			  puts '\setlength{\parskip}{0pt}'
			end
			blank
		end
		
    def compile_href(url, label)
      # @<href>{url, label} および @<href>{url} の実装メソッドを上書きする
      if /\A\#/ =~ url # 先頭が#で始まっているならアンカーへのハイパーリンクと解釈
        # XXX:この判定手法だとURLに「ch01.xhtml#foo」と別ファイルを指定しているときにはうまくいかないので、
        # より柔軟性を持たせたいならさらに条件を連ねる必要がある
        if label
          # ラベルがあるならそれを表示に利用
          macro('hyperlink', url.sub('#', ''), escape(label))
        else
          # ラベルがないなら、代替でページ参照(p.XX)に
          'p.' + macro('pageref', url.sub('#', ''))
        end
      else
        super(url, label) # ほかはデフォルト挙動を呼び出し
      end
    end

    def label(id)
      super(id)
      puts macro('hypertarget', id, '') # アンカー。文字列なしでポイントのみ作成
    end

		# # halfblankline: 文字の大きさ半分だけスペースをあけるブロックコマンド
		# Compiler.defsingle :halfblankline, 0
		# def halfblankline
		# 	puts "\\vspace{0.5zw}"
		# end

		# leadb: 太字のlead
		Compiler.defblock :leadb, 0
		def leadb(lines)
			puts "\\vspace{1.5zw}"
			latex_block('bfseries', lines)
			puts "\\vspace{1.5zw}"
		end

		# quoteb: 太字のquote
		Compiler.defblock :quoteb, 0
		def quoteb(lines)
			puts "\\vspace{1.5zw}"
			latex_block('bfseries', lines)
			puts "\\vspace{1.5zw}"
		end

		# b: 太字用のブロックコマンド。
		Compiler.defblock :b, 0
		def b(lines)
			latex_block('bfseries', lines)
		end

	end

	class LATEXBuilder
		prepend LATEXBuilderOverride
	end

end