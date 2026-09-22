# BAISOUND Voice Model 初心者向け利用ガイド

このページは、AI音声モデルを初めて扱う方に向けて、BAISOUND Voice Modelが何をするものか、何を用意すれば音声を作れるか、ほかのソフトへどう渡すかを説明します。

## まず知っておくこと

BAISOUND Voice Modelは、読み上げアプリそのものではありません。人に例えると、モデルは「声と話し方を覚えたデータ」、GPT-SoVITS Runtimeは「そのデータを使って実際に話す装置」です。

音声を作るには、次のものを組み合わせます。

| 必要なもの | 役割 | このリポジトリに含まれるか |
|---|---|---|
| BAISOUND GPTモデル | 文章の読み方や流れを組み立てる | 含まれる |
| BAISOUND SoVITSモデル | 音声を生成する | 含まれる |
| GPT-SoVITS v2Pro互換Runtime | 2つのモデルを実行する | 含まれない |
| GPT-SoVITSのpretrained model・実行環境 | Runtimeを動かす | 含まれない |
| 参照音声と正確な文字起こし | 声色、話し方、発音の手がかり | 含まれない |
| 出力先のソフト | WAVの再生、編集、配信など | 含まれない |

参照音声には、自分が利用する権利を持つ音声だけを使用してください。BGMや複数人の声が入っていない、短く明瞭な音声と、その音声で実際に話している内容を正確に書いた文章が必要です。

## 一番わかりやすい使い方

Windowsで公式APIをローカル起動する場合は、設定テンプレートとクライアントを含む[Windows向け起動例](../examples/windows/README_JP.md)も利用できます。

### 1. 利用条件を確認する

最初に[MODEL_LICENSE.md](../MODEL_LICENSE.md)を読み、予定している利用が許可されているか確認します。公開リポジトリからダウンロードできることは、自由利用や再配布の許可を意味しません。

### 2. GPT-SoVITSを用意する

このモデルは**GPT-SoVITS v2Pro**向けです。GPT-SoVITS本体と必要なpretrained modelを、[GPT-SoVITS公式リポジトリ](https://github.com/RVC-Boss/GPT-SoVITS)の案内に従って用意します。

環境構築にはPythonやGPU設定が含まれます。初めてで難しい場合は、技術担当者にセットアップを依頼してください。CPUで動かせる環境もありますが、実用的な待ち時間で連続生成するには対応GPUを使う構成が一般的です。

### 3. BAISOUNDモデルを取得する

GitとGit LFSを導入した環境で実行します。

```bash
git lfs install
git clone https://github.com/baisound/BAISOUND_VOICE_MODEL.git
cd BAISOUND_VOICE_MODEL
git lfs pull
```

Stable版では、必ず次の2ファイルを組み合わせます。

```text
models/stable/v2/baisound-voice-v2-gpt.ckpt
models/stable/v2/baisound-voice-v2-sovits.pth
```

### 4. ファイルが正しく取れたか確認する

WSLまたはLinuxでは、リポジトリ直下で次を実行します。

```bash
bash scripts/verify_repository.sh
```

モデルファイルが約130バイトしかない場合は、モデル本体ではなくGit LFSの案内ファイルだけが存在します。`git lfs pull`をもう一度実行してください。

### 5. 推論画面でモデルを選ぶ

GPT-SoVITSの推論WebUIを開き、モデルのバージョンを**v2Pro**に合わせます。そのうえで、GPTモデル欄に`.ckpt`、SoVITSモデル欄に`.pth`を指定します。画面名や起動方法はGPT-SoVITSのバージョンによって変わるため、公式リポジトリの「Open Inference WebUI」も確認してください。

### 6. 参照音声と文章を入力する

推論画面へ次の内容を指定します。

1. 利用許諾のある参照音声
2. 参照音声で実際に話している内容の正確な文字起こし
3. 参照音声の言語（日本語ならJapaneseまたは`ja`）
4. 新しく読ませたい文章
5. 新しい文章の言語

生成を実行すると、WAV音声を保存できます。声質や抑揚は、参照音声の録音状態、文章の長さ、句読点、Runtimeの設定によって変わります。

## ほかのソフトで使う

### 動画編集ソフトやDAW

GPT-SoVITSでWAVを書き出し、DaVinci Resolve、Premiere Pro、After Effects、Auditionなどへ通常の音声素材として読み込みます。モデルファイルを動画編集ソフトへ直接読み込むことはできません。

おすすめの流れは次のとおりです。

1. 台本を短い段落やセリフ単位に分ける
2. 各セリフをWAVにする
3. わかりやすい連番ファイル名で保存する
4. 編集ソフトのタイムラインへ並べる
5. 音量、間、BGMとのバランスを編集する

### OBSや配信

OBSはモデルを直接実行しません。ローカルTTS Runtimeで文章からWAVを作り、そのWAVをOBSで扱う音声出力へ再生する構成にします。配信中の待ち時間や連打に備えて、文章の受付順、重複防止、キャンセルを管理できるキュー付きRuntimeが適しています。

### Stream Deck

Stream Deckのボタンから、ローカルTTS Runtimeを呼び出すスクリプトを起動します。ボタンへ`.pth`や`.ckpt`を登録するのではありません。定型文ボタン、クリップボード読み上げ、停止ボタンなどをRuntime側で用意すると操作しやすくなります。

### Webアプリ、Bot、自作ツール

アプリからローカルのGPT-SoVITS APIへ文章を送り、返されたWAVを保存または再生します。API連携を作る方は[開発者向け統合ガイド](DEVELOPER_GUIDE_JP.md)を参照してください。

### ゲーム

固定セリフは事前にWAVを作り、ゲームの音声アセットとして組み込む方法が安定します。プレイヤー入力をその場で読む場合は、ゲームからTTSサーバーへ接続する仕組みが別途必要です。モデルや生成音声を配布物へ含める前に、必ず利用条件を確認してください。

## よくある誤解

### ダウンロードしたが、起動ファイルがない

正常です。このリポジトリはモデルの配布物であり、単体アプリではありません。GPT-SoVITS v2Pro互換Runtimeが必要です。

### 2つのモデルの片方だけで使える？

Stable版は`.ckpt`と`.pth`の2つを1組として扱います。`profiles/stable.json`に記録された組み合わせを使用してください。

### 参照音声なしで使える？

標準的なGPT-SoVITS推論では参照音声を使用します。参照音声と文字起こしはこのリポジトリに含まれないため、利用者が権利を確認したうえで用意します。

### OBSや動画編集ソフトへモデルを直接追加できる？

できません。GPT-SoVITS RuntimeでWAVに変換してから、各ソフトへ渡します。

## 困ったとき

- 取得・起動前の確認：[クイックスタート](QUICK_START_JP.md)
- 導入方法：[インストール](INSTALL_JP.md)
- 対応Runtime：[互換性](COMPATIBILITY.md)
- よくある問題：[トラブルシューティング](TROUBLESHOOTING.md)
- APIや自作アプリ連携：[開発者向け統合ガイド](DEVELOPER_GUIDE_JP.md)
- Windows起動例：[Windows向けAPIクライアント](../examples/windows/README_JP.md)
- 利用条件と悪用禁止：[利用・悪用防止ガイドライン](USAGE_POLICY_JP.md)
- 公開ナレーション音声：[Public audio samples](../samples/README.md)
- モデルの性質と制約：[Model Card](../MODEL_CARD.md)
