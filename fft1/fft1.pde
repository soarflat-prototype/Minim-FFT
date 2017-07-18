/*
 * ライブラリのインポート
 */
import ddf.minim.analysis.*;
import ddf.minim.*;

/*
 * インスタンスの宣言をする
 * 以下はMinimクラスのインスタンスに変数minimを宣言している
 */
Minim minim;

/*
 * インスタンスの宣言をする
 * 以下はAudioPlayerクラスのインスタンスに変数playerを宣言している
 */
AudioPlayer player;

/*
 * インスタンスの宣言をする
 * 以下はFFTクラスのインスタンスに変数fftを宣言している
 */
FFT fft;

void setup() {
    size(600, 600, P3D);
    frameRate(60);
    colorMode(HSB, 360, 100, 100, 100);
    minim = new Minim(this);
    player = minim.loadFile("sample.mp3", 1024);
    player.loop();
    fft = new FFT(player.bufferSize(), player.sampleRate());
    
    background(0);
}

void draw() {
    background(0);
    translate(0, height / 2);

    /*
     * forward()で、FFT解析を行う（バッファに対して順方向のFFTを行う）
     * FFTとは高速フーリエ変換のこと
     * 非常に雑な説明なるが、FFTを利用すれば周波数帯域毎の振幅の取得など
     * 音の視覚化に必要なデータを色々取得できる
     */
    fft.forward(player.mix);

    /*
     * specSize()周波数帯域数を取得し
     * 周波数帯域の数だけfor文を回す
     */
    float specSize = fft.specSize();
    for (int i = 0; i < specSize; ++i) {
        float hue = map(i, 0, specSize, 0, 360);
        float x = map(i, 0, specSize, 0, width);

        /*
         * getBand(index)で周波数帯域ごとの振幅を取得し描画に利用する
         * getBand()の引数には振幅を取得したい帯域位置を指定する
         * 今回は周波数帯域の数だけfor文を回しているため
         * 全ての帯域の振幅を取得し描画をする
         */
        float length = map(fft.getBand(i), 0, 1, 0, -5);

        stroke(hue, 50, 100);
        line(x, 0, x, length);
    }
}