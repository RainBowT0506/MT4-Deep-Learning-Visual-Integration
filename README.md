# MT4-Deep-Learning-Visual-Integration

線上課程:[活用深度學習：MT4 交易程式整合視覺模型](https://hahow.in/courses/5ca16d2972a72f002150e9b2)

專題報告: [高等人工智慧期末報告 - MT5 交易程式整合視覺模型](https://www.canva.com/design/DAFwUTb6HTc/fy87ydfDhQJRY_iZ6t37Uw/edit?utm_content=DAFwUTb6HTc&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

摘要:
本研究旨在利用隨機森林進行初步的資料模型訓練，並透過歷史K線圖形預測未來股市的趨勢。我們將訓練模型部署在雲端平台上進行視覺模型的初步訓練。

為了將預測結果應用到實際交易平台上，我們建立了一個socket server，該服務器接收來自MT4平台的請求，使用我們訓練的模型進行預測，並將預測結果回傳到MT4平台中。在MT4平台的K線圖中，我們標示出買點和賣點，以幫助交易者做出決策。

未來的工作將專注於使用GAIL（Generative Adversarial Imitation Learning）進行模型優化。GAIL是一種強大的強化學習算法，可以通過模仿專家的行為來提高模型的性能。通過應用GAIL來進行模型優化，我們期望進一步提高股市趨勢預測模型的準確性和效能。

本研究的成果將有助於投資者在股市交易中做出更明智的決策，並提供一個可靠的工具來預測未來股市的趨勢。同時，我們的方法也可以應用於其他金融市場的預測和交易策略中，具有廣泛的應用價值。

關鍵詞：隨機森林、股市趨勢預測、雲端平台、MT4平台、GAIL、強化學習、交易策略

流程
![image](https://github.com/RainBowT0506/MT4-Deep-Learning-Visual-Integration/assets/109667537/68ade763-2b43-404b-9e0c-61b070eac2ed)

買賣點判斷結果
![image](https://github.com/RainBowT0506/MT4-Deep-Learning-Visual-Integration/assets/109667537/b2114f3e-d693-4323-84c3-8e81ef2522ff)

![image](https://github.com/RainBowT0506/MT4-Deep-Learning-Visual-Integration/assets/109667537/1770dac5-50eb-432b-b534-e715df82cdc5)

模型訓練結果
![image](https://github.com/RainBowT0506/MT4-Deep-Learning-Visual-Integration/assets/109667537/50be1579-f970-4938-818f-30f412e21988)
