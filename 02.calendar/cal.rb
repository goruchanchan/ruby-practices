#!/Users/ryo/.rbenv/shims/ruby

require 'optparse'
require 'date'
require 'paint'

# オプション取扱用のオブジェクト用意
opt = OptionParser.new

# オプション格納用のハッシュ
params = {}

# オプション保持したハッシュを作る
params = ARGV.getopts("m:y:")
 
# 月のオプション指定なければ今月を指定
params["m"] = Date.today.month if(!params["m"]) 
# 年のオプション指定なければ今年を指定
params["y"] = Date.today.year if(!params["y"]) 

# カレンダーの基本部分
puts "      " + params["m"].to_s + "月 " + params["y"].to_s
puts "日 月 火 水 木 金 土"

# 表示するカレンダーの最終日を取得
date = 1
while date <= Date.new(params["y"].to_i, params["m"].to_i, -1).day
  # スタート位置調整のための空白
  if date == 1
    print "   " if Date.new(params["y"].to_i, params["m"].to_i, date).monday?
    print "      " if Date.new(params["y"].to_i, params["m"].to_i, date).tuesday?
    print "         " if Date.new(params["y"].to_i, params["m"].to_i, date).wednesday?
    print "            " if Date.new(params["y"].to_i, params["m"].to_i, date).thursday?
    print "               " if Date.new(params["y"].to_i, params["m"].to_i, date).friday?
    print "                  " if Date.new(params["y"].to_i, params["m"].to_i, date).saturday?
  end
  # 表示桁揃えるための空白調整して出力
  if date < 10
    # 色反転用
    if Date.new(params["y"].to_i, params["m"].to_i, date) == Date.today
      print Paint[" " + date.to_s, :inverse] + " "
    else
      print " " + date.to_s + " "
    end
  else
    # 色反転用
    if Date.new(params["y"].to_i, params["m"].to_i, date) == Date.today
      print Paint[date.to_s, :inverse] + " "
    else
      print date.to_s + " "
    end
  end
  # 土曜日の場合、改行する
  puts if  Date.new(params["y"].to_i, params["m"].to_i,date).saturday?

 date += 1
end

# カレンダー出力に連続してプロンプトが表示されないように改行しておく
puts
puts
