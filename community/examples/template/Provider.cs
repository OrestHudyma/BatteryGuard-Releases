using System;
using BatteryGuard.PluginApi;
namespace Community.Template {
    // Safe starting point: no hardware calls. Replace only after protocol evidence exists.
    public sealed class Provider:IChargeProvider {
        public void Initialize(HardwareIdentity machine){}
        public ControlStatus ReadStatus(){return new ControlStatus{State=ChargeControlState.Unknown};}
        public string CaptureRecovery(){throw new NotSupportedException("Protocol and recovery are not implemented.");}
        public void SetPaused(bool paused){throw new NotSupportedException();}
        public void SetThresholds(int? resumeAt,int stopAt){throw new NotSupportedException();}
        public void Restore(string state){throw new NotSupportedException();}
        public void Dispose(){}
    }
}
