using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace AuthServer.Data.Migrations.IdentityServer
{
    public partial class InitialConfig : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                "Created",
                "IdentityResources",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<bool>(
                "NonEditable",
                "IdentityResources",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                "Updated",
                "IdentityResources",
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                "Value",
                "ClientSecrets",
                maxLength: 4000,
                nullable: false,
                oldClrType: typeof(string),
                oldMaxLength: 2000);

            migrationBuilder.AlterColumn<string>(
                "Type",
                "ClientSecrets",
                maxLength: 250,
                nullable: false,
                oldClrType: typeof(string),
                oldMaxLength: 250,
                oldNullable: true);

            migrationBuilder.AddColumn<DateTime>(
                "Created",
                "ClientSecrets",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                "Created",
                "Clients",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<int>(
                "DeviceCodeLifetime",
                "Clients",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                "LastAccessed",
                "Clients",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                "NonEditable",
                "Clients",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                "Updated",
                "Clients",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                "UserCodeType",
                "Clients",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                "UserSsoLifetime",
                "Clients",
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                "Value",
                "ApiSecrets",
                maxLength: 4000,
                nullable: false,
                oldClrType: typeof(string),
                oldMaxLength: 2000,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                "Type",
                "ApiSecrets",
                maxLength: 250,
                nullable: false,
                oldClrType: typeof(string),
                oldMaxLength: 250,
                oldNullable: true);

            migrationBuilder.AddColumn<DateTime>(
                "Created",
                "ApiSecrets",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                "Created",
                "ApiResources",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                "LastAccessed",
                "ApiResources",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                "NonEditable",
                "ApiResources",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                "Updated",
                "ApiResources",
                nullable: true);

            migrationBuilder.CreateTable(
                "ApiProperties",
                table => new
                {
                    Id = table.Column<int>()
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    Key = table.Column<string>(maxLength: 250),
                    Value = table.Column<string>(maxLength: 2000),
                    ApiResourceId = table.Column<int>()
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ApiProperties", x => x.Id);
                    table.ForeignKey(
                        "FK_ApiProperties_ApiResources_ApiResourceId",
                        x => x.ApiResourceId,
                        "ApiResources",
                        "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                "IdentityProperties",
                table => new
                {
                    Id = table.Column<int>()
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    Key = table.Column<string>(maxLength: 250),
                    Value = table.Column<string>(maxLength: 2000),
                    IdentityResourceId = table.Column<int>()
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_IdentityProperties", x => x.Id);
                    table.ForeignKey(
                        "FK_IdentityProperties_IdentityResources_IdentityResourceId",
                        x => x.IdentityResourceId,
                        "IdentityResources",
                        "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                "IX_ApiProperties_ApiResourceId",
                "ApiProperties",
                "ApiResourceId");

            migrationBuilder.CreateIndex(
                "IX_IdentityProperties_IdentityResourceId",
                "IdentityProperties",
                "IdentityResourceId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                "ApiProperties");

            migrationBuilder.DropTable(
                "IdentityProperties");

            migrationBuilder.DropColumn(
                "Created",
                "IdentityResources");

            migrationBuilder.DropColumn(
                "NonEditable",
                "IdentityResources");

            migrationBuilder.DropColumn(
                "Updated",
                "IdentityResources");

            migrationBuilder.DropColumn(
                "Created",
                "ClientSecrets");

            migrationBuilder.DropColumn(
                "Created",
                "Clients");

            migrationBuilder.DropColumn(
                "DeviceCodeLifetime",
                "Clients");

            migrationBuilder.DropColumn(
                "LastAccessed",
                "Clients");

            migrationBuilder.DropColumn(
                "NonEditable",
                "Clients");

            migrationBuilder.DropColumn(
                "Updated",
                "Clients");

            migrationBuilder.DropColumn(
                "UserCodeType",
                "Clients");

            migrationBuilder.DropColumn(
                "UserSsoLifetime",
                "Clients");

            migrationBuilder.DropColumn(
                "Created",
                "ApiSecrets");

            migrationBuilder.DropColumn(
                "Created",
                "ApiResources");

            migrationBuilder.DropColumn(
                "LastAccessed",
                "ApiResources");

            migrationBuilder.DropColumn(
                "NonEditable",
                "ApiResources");

            migrationBuilder.DropColumn(
                "Updated",
                "ApiResources");

            migrationBuilder.AlterColumn<string>(
                "Value",
                "ClientSecrets",
                maxLength: 2000,
                nullable: false,
                oldClrType: typeof(string),
                oldMaxLength: 4000);

            migrationBuilder.AlterColumn<string>(
                "Type",
                "ClientSecrets",
                maxLength: 250,
                nullable: true,
                oldClrType: typeof(string),
                oldMaxLength: 250);

            migrationBuilder.AlterColumn<string>(
                "Value",
                "ApiSecrets",
                maxLength: 2000,
                nullable: true,
                oldClrType: typeof(string),
                oldMaxLength: 4000);

            migrationBuilder.AlterColumn<string>(
                "Type",
                "ApiSecrets",
                maxLength: 250,
                nullable: true,
                oldClrType: typeof(string),
                oldMaxLength: 250);
        }
    }
}