using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace AuthServer.Services.DbServices.Interfaces
{
    public interface IDbService<TEntity> where TEntity : class
    {
        IEnumerable<TEntity> GetAll();
        TEntity GetById(Guid id);
        Task CreateAsync(TEntity applicationClient, CancellationToken cancellationToken);
        Task UpdateAsync(TEntity update, CancellationToken cancellationToken);
        Task<bool> DeleteByIdAsync(Guid id, CancellationToken cancellationToken);
        ValueTask DisposeAsync();
    }
}