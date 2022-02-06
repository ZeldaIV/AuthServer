using System;
using System.IO;
using System.Security.Cryptography;

namespace AuthServer.Services.Cryptography;

public static class Encryption
{
    public static byte[] EncryptStringToBytes(string s, byte[] key, byte[] iv)
    {
        byte[] encrypted;

        using var aes = Aes.Create();
        aes.Key = key;
        aes.IV = iv;

        var encryptor = aes.CreateEncryptor(key, iv);
        using var ms = new MemoryStream();
        using var encrypt = new CryptoStream(ms, encryptor, CryptoStreamMode.Write);
        using var sw = new StreamWriter(encrypt);
        try
        {
            sw.Write(s);
            sw.Close();
            ms.Close();
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            throw;
        }
        finally
        {
            encrypt.Clear();
        }
        encrypted = ms.ToArray();
        
        return encrypted;
    }

    public static string DecryptStringFromBytes(byte[] cipherText, byte[] key, byte[] iv)
    {
        string result;
        using var aes = Aes.Create();
        aes.Key = key;
        aes.IV = iv;

        var decryptor = aes.CreateDecryptor(key, iv);

        using var ms = new MemoryStream(cipherText);
        using var decrypt = new CryptoStream(ms, decryptor, CryptoStreamMode.Read);
        using var sr = new StreamReader(decrypt);
        try
        {
            result = sr.ReadToEnd();
            sr.Close();
            ms.Close();
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            throw;
        }
        finally
        {
            decrypt.Clear();
        }

        return result;
    }
}