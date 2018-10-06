

namespace AuthServer.Configuration {
    public class TokenSigningConfiguration {
        public string AuthServerSigningCertificatePath {get; set;}
        public string AuthServerSigningCertificatePassword {get; set;}
    }

    public class AdministrationConfiguration {
        public string AuthServerAdministrator {get; set;}
        public string AuthServerAdministratorPassword {get; set;}
    }
}