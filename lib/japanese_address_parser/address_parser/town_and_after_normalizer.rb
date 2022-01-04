# frozen_string_literal: true

require 'number_to_kanji'

module JapaneseAddressParser
  module AddressParser
    module TownAndAfterNormalizer
      OLD_KANJI = %w[亞 圍 壹 榮 驛 應 櫻 假 會 懷 覺 樂 陷 歡 氣 戲 據 挾 區 徑 溪 輕 藝 儉 圈 權 嚴 恆 國 齋 雜 蠶 殘 兒 實 釋 從 縱 敍 燒 條 剩 壤 釀 眞 盡 醉 髓 聲 竊 淺 錢 禪 爭 插 騷 屬 對 滯 擇 單 斷 癡 鑄 敕 鐵 傳 黨 鬪 屆 腦 廢 發 蠻 拂 邊 瓣 寶 沒 滿 藥 餘 樣 亂 兩 禮 靈 爐 灣 惡 醫 飮 營 圓 歐 奧 價 繪 擴 學 罐 勸 觀 歸 犧 擧 狹 驅 莖 經 繼 缺 劍 檢 顯 廣 鑛 碎 劑 參 慘 絲 辭 舍 壽 澁 肅 將 證 乘 疊 孃 觸 寢 圖 穗 樞 齊 攝 戰 潛 雙 莊 裝 藏 續 體 臺 澤 膽 彈 蟲 廳 鎭 點 燈 盜 獨 貳 霸 賣 髮 祕 佛 變 辯 豐 飜 默 與 譽 謠 覽 獵 勵 齡 勞 壓 爲 隱 衞 鹽 毆 穩 畫 壞 殼 嶽 卷 關 顏 僞 舊 峽 曉 勳 惠 螢 鷄 縣 險 獻 驗 效 號 濟 册 棧 贊 齒 濕 寫 收 獸 處 稱 奬 淨 繩 讓 囑 愼 粹 隨 數 靜 專 踐 纖 壯 搜 總 臟 墮 帶 瀧 擔 團 遲 晝 聽 遞 轉 當 稻 讀 惱 拜 麥 拔 濱 竝 辨 舖 襃 萬 譯 豫 搖 來 龍 壘 隸 戀 樓 鰺 鶯 蠣 攪 竈 灌 諫 頸 礦 蘂 靱 賤 壺 礪 檮 濤 邇 蠅 檜 儘 藪 籠].freeze
      NEW_KANJI = %w[亜 囲 壱 栄 駅 応 桜 仮 会 懐 覚 楽 陥 歓 気 戯 拠 挟 区 径 渓 軽 芸 倹 圏 権 厳 恒 国 斎 雑 蚕 残 児 実 釈 従 縦 叙 焼 条 剰 壌 醸 真 尽 酔 髄 声 窃 浅 銭 禅 争 挿 騒 属 対 滞 択 単 断 痴 鋳 勅 鉄 伝 党 闘 届 脳 廃 発 蛮 払 辺 弁 宝 没 満 薬 余 様 乱 両 礼 霊 炉 湾 悪 医 飲 営 円 欧 奥 価 絵 拡 学 缶 勧 観 帰 犠 挙 狭 駆 茎 経 継 欠 剣 検 顕 広 鉱 砕 剤 参 惨 糸 辞 舎 寿 渋 粛 将 証 乗 畳 嬢 触 寝 図 穂 枢 斉 摂 戦 潜 双 荘 装 蔵 続 体 台 沢 胆 弾 虫 庁 鎮 点 灯 盗 独 弐 覇 売 髪 秘 仏 変 弁 豊 翻 黙 与 誉 謡 覧 猟 励 齢 労 圧 為 隠 衛 塩 殴 穏 画 壊 殻 岳 巻 関 顔 偽 旧 峡 暁 勲 恵 蛍 鶏 県 険 献 験 効 号 済 冊 桟 賛 歯 湿 写 収 獣 処 称 奨 浄 縄 譲 嘱 慎 粋 随 数 静 専 践 繊 壮 捜 総 臓 堕 帯 滝 担 団 遅 昼 聴 逓 転 当 稲 読 悩 拝 麦 抜 浜 並 弁 舗 褒 万 訳 予 揺 来 竜 塁 隷 恋 楼 鯵 鴬 蛎 撹 竃 潅 諌 頚 砿 蕊 靭 賎 壷 砺 梼 涛 迩 蝿 桧 侭 薮 篭].freeze
      OLD_NEW_KAMJI_MAPPING = ::JapaneseAddressParser::AddressParser::TownAndAfterNormalizer::OLD_KANJI.map.with_index { |old, index| [old, ::JapaneseAddressParser::AddressParser::TownAndAfterNormalizer::NEW_KANJI[index]] }.to_h.freeze

      public_constant :OLD_KANJI
      public_constant :NEW_KANJI
      public_constant :OLD_NEW_KAMJI_MAPPING

      def call(town_and_after)
        # 旧字体を新字体に置き換える。
        normalized = town_and_after.gsub(/[#{OLD_KANJI.join}]/) { |old_kanji| ::JapaneseAddressParser::AddressParser::TownAndAfterNormalizer::OLD_NEW_KAMJI_MAPPING[old_kanji] }

        # 全角の数字を半角に変換する。
        normalized = normalized.tr('０-９', '0-9')

        # ハイフンのような文字をハイフンに変換する。
        normalized = normalized.gsub(/[‐－―ー−]/, '-')

        # 「3条」のような表記に含まれる英数字を漢数字に変換する。
        normalized =
          normalized.gsub(/(\D*)(\d*)([条|丁目].*)/) do
            if ::Regexp.last_match(2).empty?
              normalized
            else
              "#{::Regexp.last_match(1)}#{::NumberToKanji.call(Integer(::Regexp.last_match(2), 10))}#{::Regexp.last_match(3)}"
            end
          end

        normalized
      end

      module_function :call
    end
  end
end
