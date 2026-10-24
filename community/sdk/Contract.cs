using System;
using System.Reflection;
[assembly: AssemblyVersion("1.0.0.0")]
namespace BatteryGuard.PluginApi {
    // Changing an existing signature requires a new API major version.
    public enum ControlKind { MonitorOnly, SoftwarePause, UpperLimit, DualLimits }
    public enum ChargeControlState { Unknown, Automatic, Paused, Configured }
    public sealed class HardwareIdentity {
        public string Manufacturer, Model, Board, Bios;
    }
    public sealed class ControlStatus {
        public ChargeControlState State;
        public int? Lower, Upper;
    }
    public interface IChargeProvider : IDisposable {
        // Constructors and Initialize must not change firmware state.
        void Initialize(HardwareIdentity machine);
        ControlStatus ReadStatus();
        // Opaque, bounded JSON/string sufficient for idempotent Restore in another process.
        string CaptureRecovery();
        void SetPaused(bool paused);
        void SetThresholds(int? resumeAt, int stopAt);
        void Restore(string recovery);
    }
}
