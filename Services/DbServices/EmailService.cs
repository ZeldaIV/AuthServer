using System;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data;
using AuthServer.Data.Models;
using AuthServer.Services.DbServices.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AuthServer.Services.DbServices;

public class EmailService : IEmailService, IAsyncDisposable, IDisposable
{
    private readonly ApplicationDbContext _context;

    public EmailService(IDbContextFactory<ApplicationDbContext> context)
    {
        _context = context.CreateDbContext();
    }
    
    public ValueTask DisposeAsync()
    {
        
        if (_context is IAsyncDisposable ad)
        {
            return ad.DisposeAsync();
        }
        _context.Dispose();
        return ValueTask.CompletedTask;
    }
    
    public void Dispose()
    {
        _context?.Dispose();
    }

    public async Task CreateAsync(EmailServer server, CancellationToken cancellationToken)
    {
        var entity = await _context.EmailServers.FirstOrDefaultAsync(s => s.Id == server.Id, cancellationToken);
        if (entity == null)
        {
            // TODO: Handle errors
            await _context.EmailServers.AddAsync(Encrypt(server), cancellationToken);
            await _context.SaveChangesAsync(cancellationToken);
        }
    }

    public async Task<EmailServer> GetServer(CancellationToken cancellationToken)
    {
        var server = await _context.EmailServers.FirstOrDefaultAsync(cancellationToken);
        return server != null ? Decrypt(server) : null;
    }

    public async Task UpdateAsync(EmailServer update, CancellationToken cancellationToken)
    {
        var entity = await _context.EmailServers.FirstOrDefaultAsync(s => s.Id == update.Id, cancellationToken);
        if (entity != null)
        {
            entity.Host = update.Host;
            entity.Port = update.Port;
            entity.FromAddress = update.FromAddress;
            entity.UserName = update.UserName;
            entity.FromDisplayName = entity.FromDisplayName;
            await _context.SaveChangesAsync(cancellationToken);
        }
    }

    private EmailServer Encrypt(EmailServer server)
    {
        // TODO: Get key from elsewhere
        byte[] key = {
            0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
            0x09, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16
        };
        using var aes = Aes.Create();
        var iv = aes.IV;
        var result = Cryptography.Encryption.EncryptStringToBytes(server.Password, key, iv);
        
        server.Password = Convert.ToBase64String(result);
        server.IV = Convert.ToBase64String(iv);
        
        return server;
    }

    private EmailServer Decrypt(EmailServer server)
    {
        // TODO: Get key from elsewhere
        byte[] key = {
            0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
            0x09, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16
        };
        
        var iv = Convert.FromBase64String(server.IV);
        var passwordBytes = Convert.FromBase64String(server.Password);
        var result = Cryptography.Encryption.DecryptStringFromBytes(passwordBytes, key, iv);
        
        server.Password = result;
        server.IV = Encoding.Unicode.GetString(iv);
        
        return server;
    }
    
}