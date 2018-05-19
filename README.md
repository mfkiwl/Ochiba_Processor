# Ochiba_Processor
Ochibaは、低リソース消費・高周波数駆動が可能なRISC-V RV32I対応のプロセッサです。

Ochiba is a RISC-V RV32I compatible processor featuring low LUT resource consumption and high frequency drive.
![ochiba](https://user-images.githubusercontent.com/22812890/40268190-1e9d915a-5ba4-11e8-9a5a-2ed54213575b.jpg)

![ochiba](https://user-images.githubusercontent.com/22812890/40229307-d2f01dfc-5ace-11e8-9fda-9850d3c526d2.jpg)


# 概要
## 低リソース消費
同命令セットを持つ競合実装と比較して、極端にというわけではありませんが小規模な実装です。

## 高周波数駆動
競合実装と比較して、同じFPGAに実装した場合駆動周波数が高いです。

参考：
Intel CycloneV 5CEBA4F23C7N FPGAにて、100MHzでの駆動が可能です。

## 環境非依存
IPを利用せずにすべてVerilogで記述されているため、FPGAベンダーを選びません。

## Verilog記述
一般的に利用されるVerilog HDLで記述されているため、簡単に読んだり改造したりすることができます。

# 実装
インオーダー実行、6段パイプラインを持つプロセッサです。

比較的長いパイプラインを持つのが特徴です。

# ファイル構造
 - Ochiba_RV32I
    - src
        - Ochiba_RV32I.v
        - Ochiba_RV32I-dp.v
        - Ochiba_RV32I-Fetch.v
        - Ochiba_RV32I-Decode.v
        - Ochiba_RV32I-RegisterFile.v
        - Ochiba_RV32I-ALU.v
        - Ochiba_RV32I-MemoryAccess.v
        - Ochiba_RV32I-WriteBack.v
        - Ochiba_RV32I-sysreg.v
        - ram.v
        - io.v
        - test.v
        
それぞれのファイルの詳しい内容については、src内のreadmeをご覧ください。

# ライセンス
現在開発中のため、ソースは公開しますが使用は研究目的での利用および個人的なもののみとさせて頂きます。
商用目的での利用はできません。
また、個人の実装のためシステムレジスタ等RISC-V規格に完全に準拠できていない場所もあります。
そのような個所も一切のサポートはいたしませんのでご了承ください。

# 開発者
Sodium (sodium@sfc.wide.ad.jp)
