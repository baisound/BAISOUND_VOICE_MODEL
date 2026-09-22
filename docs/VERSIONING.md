# Versioning

Public releaseはSemantic Versioningを使用します。

- Major: モデル世代または互換性の大きな変更
- Minor: 後方互換のprofile・metadata・補助モデル追加
- Patch: bytesを変えない文書、manifest、installer、検証修正

内部Task番号、候補ID、epoch、stepはrelease名に使用しません。候補モデルのepoch/stepは、候補を識別するための説明的なpublic filenameに限って保持できます。

Stable、Candidate、Experimentalは別channelです。Stable profileの変更はrelease manifestとchecksum更新を必須とします。
