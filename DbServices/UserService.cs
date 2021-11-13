using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data;
using AuthServer.DbServices.Interfaces;
using AuthServer.Dtos;
using Mapster;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Serilog;

namespace AuthServer.DbServices
{
    public sealed class UserService : IUserService, IAsyncDisposable
    {
        private readonly ApplicationDbContext _context;

        public UserService(IDbContextFactory<ApplicationDbContext> context)
        {
            _context = context.CreateDbContext();
        }

        public ValueTask DisposeAsync()
        {
            return _context.DisposeAsync();
        }

        public async Task AddUser(UserDto user, CancellationToken cancellationToken)
        {
            var userModel = user.Adapt<IdentityUser>();

            try
            {
                await _context.Users.AddAsync(userModel, cancellationToken);
                await _context.SaveChangesAsync(cancellationToken);
            }
            catch (DbUpdateException e)
            {
                Log.Logger.Error(e.Message);
                throw;
            }
        }

        public List<UserDto> GetUsers()
        {
            return _context.Users.Adapt<List<UserDto>>();
        }

        public UserDto GetUserById(string id)
        {
            try
            {
                return _context.Users.Single(u => u.Id == id).Adapt<UserDto>();
            }
            catch (InvalidOperationException e)
            {
                Log.Logger.Error(e.Message);
                throw;
            }
        }

        public async Task<bool> DeleteByIdAsync(string id, CancellationToken cancellationToken)
        {
            try
            {
                var result = await _context.Users.SingleAsync(r => r.Id == id, cancellationToken);
                _context.Users.Remove(result);
                return true;
            }
            catch (InvalidOperationException e)
            {
                Log.Logger.Error(e.Message);
                return false;
            }
        }
    }
}