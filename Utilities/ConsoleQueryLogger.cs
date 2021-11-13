using System;
using System.Diagnostics;
using System.Linq;
using System.Text;
using HotChocolate.Execution;
using HotChocolate.Execution.Instrumentation;
using Microsoft.Extensions.Logging;

namespace AuthServer.Utilities
{
    public class ConsoleQueryLogger : ExecutionDiagnosticEventListener
    {
        private static Stopwatch _queryTimer;
        private readonly ILogger<ConsoleQueryLogger> _logger;

        public ConsoleQueryLogger(ILogger<ConsoleQueryLogger> logger)
        {
            _logger = logger;
        }

        public override IDisposable ExecuteRequest(IRequestContext context)
        {
            return new RequestScope(_logger, context);
        }


        private class RequestScope : IDisposable
        {
            private readonly IRequestContext _context;
            private readonly ILogger<ConsoleQueryLogger> _logger;

            public RequestScope
            (ILogger<ConsoleQueryLogger> logger,
                IRequestContext context)
            {
                _logger = logger;
                _context = context;
                _queryTimer = new Stopwatch();
                _queryTimer.Start();
            }

            public void Dispose()
            {
                if (_context.Document is null) return;

                StringBuilder stringBuilder =
                    new(_context.Document.ToString(true));
                stringBuilder.AppendLine();
                if (_context.Variables != null)
                {
                    var variablesConcrete =
                        _context.Variables!.ToList();
                    if (variablesConcrete.Count > 0)
                    {
                        stringBuilder.AppendFormat($"Variables {Environment.NewLine}");
                        try
                        {
                            foreach (var variableValue in _context.Variables!)
                            {
                                string PadRightHelper
                                    (string existingString, int lengthToPadTo)
                                {
                                    if (string.IsNullOrEmpty(existingString))
                                        return "".PadRight(lengthToPadTo);
                                    if (existingString.Length > lengthToPadTo)
                                        return existingString.Substring(0, lengthToPadTo);
                                    return existingString + " ".PadRight(lengthToPadTo - existingString.Length);
                                }

                                stringBuilder.AppendFormat(
                                    $"  {PadRightHelper(variableValue.Name, 20)} :  {PadRightHelper(variableValue.Value.ToString(), 20)}: {variableValue.Type}");
                                stringBuilder.AppendFormat($"{Environment.NewLine}");
                            }
                        }
                        catch
                        {
                            // all input type records will land here.
                            stringBuilder.Append("  Formatting Variables Error. Continuing...");
                            stringBuilder.AppendFormat($"{Environment.NewLine}");
                        }
                    }
                }

                _queryTimer.Stop();
                stringBuilder.AppendFormat(
                    $"Elapsed time for query is {_queryTimer.Elapsed.TotalMilliseconds:0.#} milliseconds.");
                _logger.LogInformation(stringBuilder.ToString());
            }
        }
    }
}