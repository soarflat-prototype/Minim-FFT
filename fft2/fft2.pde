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

/*
 * FFTサイズを指定する
 * FFTサイズとは一連の時間領域データを何分割するかどうかの値
 * 例えば、FFTサイズが512の場合0~1のデータを512分割して返す
 * FFTサイズが大きいほど、分割数が多くなるのでデータは細かくなる
 */
int fftSize = 2048;

float[] degree = new float[fftSize];
float[] velocity = new float[fftSize];

void setup() {
    size(600, 600, P3D);
    frameRate(60);
    colorMode(HSB, 360, 100, 100, 100);
    minim = new Minim(this);
    player = minim.loadFile("sample.mp3", 1024);
    player.loop();
    fft = new FFT(player.bufferSize(), fftSize);
    
    background(0);

    for (int i = 0; i < fftSize; ++i) {
        degree[i] = 0;
        velocity[i] = 0;
    }
}

void draw() {
    background(0, 50);
    noStroke();
    translate(width / 2, height / 2);

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

    /*
     * getBand(index)で周波数帯域ごとの振幅を取得し描画に利用する
     * getBand()の引数には振幅を取得したい帯域位置を指定する
     * 今回は周波数帯域の数だけfor文を回しているため
     * 全ての帯域の振幅を取得し描画をする
     */
    for (int i = 0; i < specSize; ++i) {
        float hue = map(i, 0, specSize, 0, 360);
        float x = map(i, 0, specSize, 0, width);

        /*
         * getBand()を利用して直径の値を求める
         * 直径に対してpow(1.1, 2)を乗算しているが
         * 直径が大きいほど大きな値を返すためのチューニング値
         */
        float diameter = map(fft.getBand(i), 0, 1, 0.1, 0.5) * pow(1.1, 2);

        /*
         * getBand()を利用して速度を加算
         * 速度が早すぎると描画がよくわからなくなるため
         * 一定速度を超えたらpow(0.1, 2)を乗算
         */
        velocity[i] += map(fft.getBand(i), 0, 1, 0, 0.02);
        if (velocity[i] > 10) velocity[i] *= pow(0.1, 2);

        degree[i] += velocity[i];

        pushMatrix();

        rotate(radians(degree[i]));

        fill(hue, 100, 100, 100);
        
        ellipse(x, 0, diameter, diameter);

        popMatrix();
    }
}