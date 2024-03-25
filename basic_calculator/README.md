# Basic Calculator
   
[https://m7sm4-2iaaa-aaaab-qabra-cai.raw.ic0.app/?tag=83358993](https://m7sm4-2iaaa-aaaab-qabra-cai.raw.ic0.app/?tag=83358993)https://m7sm4-2iaaa-aaaab-qabra-cai.raw.ic0.app/?tag=83358993


# Hesap Makinesi Akıllı Sözleşmesi

Bu proje, Internet Computer Internship Bootcamp için temel bir örnek akıllı sözleşme olan bir hesap makinesi uygulamasını içerir. Bu akıllı sözleşme, toplama, çıkarma, çarpma ve bölme gibi temel matematiksel işlemleri gerçekleştirebilir.

## Nasıl Kullanılır

1. **Kurulum:** İnternet Bilgisayar'ın bir örneğine erişim sağlayın ve Motoko dilini kullanarak bu akıllı sözleşmeyi dağıtın.

2. **İşlevler:**
   - `toplam`: Verilen bir sayıyı mevcut değere ekler.
   - `cikarma`: Mevcut değerden verilen sayıyı çıkarır.
   - `carpma`: Mevcut değeri verilen sayıyla çarpar.
   - `bolme`: Mevcut değeri verilen sayıya böler. Eğer verilen sayı sıfırsa, bir hata döndürür.

3. **Asenkron İşlemler:** Her işlev, asenkron bir şekilde çalışır, böylece paralel hesaplama işlemleri gerçekleştirilebilir.

4. **Temizleme:** `temizle` işlevi, hesap makinesinin mevcut değerini sıfırlar.

## Örnek Kullanım

```motoko
// Hesap makinesi örneği
actor hesap_makinesi
{
  var hucre: Int = 0;

  //toplama fonksiyonu
  public func toplam(s: Int) : async Int{
    hucre += s;
    hucre
  };

  //çıkarma fonksiyonu
  public func cikarma(s: Int) : async Int{
    hucre -= s;
    hucre
  };

  //çarpma fonksiyonu
  public func carpma(s: Int) : async Int{
    hucre *= s;
    hucre
  };

  //bölme fonksiyonu
  public func bolme(s: Int) : async ?Int{
    if (s == 0)  {
      null
    } else {
      hucre /= s;
      ?hucre
    }
  };

  //temizle fonksiyonu
  public func temizle() : () {
    hucre := 0;
  };
};

```
## Motoko Dili
Motoko, Internet Computer'ın yazılım geliştirme için özel olarak tasarlanmış bir programlama dilidir. Bu dil, Internet Computer'ın ağ üzerinde dağıtılmış uygulamaları çalıştırmak için kullanılan bir akıllı sözleşme dili olarak hizmet verir. Motoko, actor tabanlı bir model kullanır ve asenkron işlemleri destekler. Bu nedenle, Internet Computer üzerinde çalışan uygulamaları geliştirmek için yaygın olarak kullanılan bir dildir. Yukarıdaki kod, Motoko dilinde yazılmış bir hesap makinesi akıllı sözleşmesi örneğidir.
