using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using AuthServer.Data;
using AuthServer.Data.Models;
using AuthServer.DbServices.Interfaces;
using AuthServer.Dtos;
using Mapster;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Serilog;

namespace AuthServer.DbServices
{
    public sealed class UserService : IUserService, IAsyncDisposable, IDisposable
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ApplicationDbContext _context;

        public UserService(IDbContextFactory<ApplicationDbContext> context, UserManager<ApplicationUser> userManager)
        {
            _userManager = userManager;
            _context = context.CreateDbContext();
        }

        public ValueTask DisposeAsync()
        {
            _userManager.Dispose();
            if (_context is IAsyncDisposable ad)
            {
                return ad.DisposeAsync();
            }
            _context.Dispose();
            return ValueTask.CompletedTask;
        }

        public async Task CreateAsync(UserDto user, CancellationToken cancellationToken)
        {
            var userModel = user.Adapt<ApplicationUser>();

            var entity = await _userManager.FindByIdAsync(user.Id.ToString());
            if (entity == null)
            {
                await _userManager.CreateAsync(userModel);
            }
        }

        public async Task UpdateAsync(UserDto update, CancellationToken cancellationToken)
        {
            var userModel = update.Adapt<ApplicationUser>();
            
            var entity = await _userManager.FindByIdAsync(update.Id.ToString());
            if (entity != null)
            {
                await _userManager.UpdateAsync(userModel);
            }
            
        }

        public IEnumerable<UserDto> GetAll()
        {
            return _context.Users.Adapt<List<UserDto>>();
        }

        public UserDto GetById(Guid id)
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

        public async Task<bool> DeleteByIdAsync(Guid id, CancellationToken cancellationToken)
        {
            var user = await _userManager.FindByIdAsync(id.ToString());
            if (user == null) return false;
            
            await _userManager.DeleteAsync(user);
            return true;

        }

        public async Task<bool> AddUserClaims(Guid userId, List<Guid> claimIds)
        {
            var user = await _userManager.FindByIdAsync(userId.ToString());
            var userClaims = _context.ClaimTypes.Where(c => claimIds.Contains(c.Id)).Select(c => new Claim(c.Name, c.Value));
            
            if (user == null || !userClaims.Any()) return false;
            
            var result = await _userManager.AddClaimsAsync(user, userClaims);
            return result.Succeeded;
        }

        public async Task<bool> RemoveClaimFromUser(Guid userId, string claimType, CancellationToken cancellationToken)
        {
            var user = await _userManager.FindByIdAsync(userId.ToString());
            var userClaim = await _context.UserClaims.SingleOrDefaultAsync(c => c.UserId == userId && c.ClaimType == claimType, cancellationToken);
            if (user == null || userClaim == null) return false;

            var result = await _userManager.RemoveClaimAsync(user, userClaim.ToClaim());
            return result.Succeeded;

        }

        public async Task<List<Claim>> GetUserClaims(Guid id, CancellationToken cancellationToken)
        {
            var user = await _userManager.FindByIdAsync(id.ToString());
            
            if (user == null) return new List<Claim>();
            
            var result = await _userManager.GetClaimsAsync(user);
            return result.ToList();

        }

        public void Dispose()
        {
            _userManager?.Dispose();
            _context?.Dispose();
        }
    }
}