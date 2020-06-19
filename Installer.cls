Class App.Installer
{

XData setup
{
<Manifest>
  <Default Name="SourceDir" Value="#{$system.Process.CurrentDirectory()}src"/>

  <Namespace Name="IRISAPP" Code="IRISAPP" Data="IRISAPP" Create="yes" Ensemble="no">

    <Configuration>
      <Database Name="IRISAPP" Dir="/opt/irisapp/data" Create="yes"/>

  
    </Configuration>
  </Namespace>

</Manifest>
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  #; Let XGL document generate code for this method. 
  Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup")
}

ClassMethod LockRegistry(pUsername As %String, pPassword As %String, Namespace, NewPassSys) As %Status
{
	new $namespace
    set $namespace="%SYS"

    // 1. Cteate user 
        set tSC= ##class(App.Security.LockDown).CreateUser(pUsername, "%DB_"_Namespace, pPassword, "ZMP registry user",Namespace)
        If $$$ISERR(tSC) q tSC
        w !,"Create user "_pUsername

    // 2. Add privelege
        set tSC=##class(App.Security.LockDown).addSQLPrivilege(Namespace, "1,ZPM.Package", "s", "UnknownUser")
        set tSC=##class(App.Security.LockDown).addSQLPrivilege(Namespace, "1,ZPM.Package", "s", pUsername)
        set tSC=##class(App.Security.LockDown).addSQLPrivilege(Namespace, "1,ZPM.Package_dependencies", "s", pUsername)
        set tSC=##class(App.Security.LockDown).addSQLPrivilege(Namespace, "1,ZPM_Analytics.Event", "s", pUsername)
        set tSC=##class(App.Security.LockDown).addSQLPrivilege(Namespace, "9,ZPM.Package_Extent", "e", pUsername)
        set tSC=##class(App.Security.LockDown).addSQLPrivilege(Namespace, "9,ZPM_Analytics.Event_Extent", "e", pUsername)
        If $$$ISERR(tSC) q tSC
        w !,"Add priveleges "

    // 3. LockDown
        set tSC= ##class(App.Security.LockDown).Apply(NewPassSys)
        If $$$ISERR(tSC) q tSC

    // 4. Modify /registry AutheEnabled = 96 ; Password,Unauthenticated
        set prop("AutheEnabled")=96
        set tSC=##class(Security.Applications).Modify("/registry",.prop)
        If $$$ISERR(tSC) q tSC
        w !,"Modify /registry "

    // 5. Modify /api/monitor AutheEnabled = 64 ; Unauthenticated
        set prop("AutheEnabled")=64
        set tSC=##class(Security.Applications).Modify("/api/monitor",.prop)
        If $$$ISERR(tSC) q tSC
        w !,"Modify /api/monitor "

    // 6. Modify service_terminal AutheEnabled = 48 ; Operating System,Password
        set name="%service_terminal"
        set prop("Enabled")=1
        set prop("AutheEnabled")=48 ; Operating System,Password
        set tSC=##class(Security.Services).Modify(name,.prop)
        If $$$ISERR(tSC) q tSC
        w !,"Modify service terminal"
	q tSC
}

}
