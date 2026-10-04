classdef BMS_TestSuite < matlab.unittest.TestCase
    properties
        Logs
    end

    methods(TestClassSetup)
        function runSimulation(testCase)
            addpath(genpath(pwd));
            run('scripts/BMS_init.m');
            simOut = sim('models/bms_pack.slx', 'ReturnWorkspaceOutputs', 'on');
            if isprop(simOut, 'logsout')
                testCase.Logs = simOut.logsout;
            else
                testCase.Logs = evalin('base', 'logsout');
            end
        end
    end

    methods(Test)
        function testSoCConvergence(testCase)
            s1 = testCase.Logs.get('SoC1_true').Values.Data;
            s2 = testCase.Logs.get('SoC2_true').Values.Data;
            s3 = testCase.Logs.get('SoC3_true').Values.Data;
            finalSpread = (max([s1(end), s2(end), s3(end)]) - min([s1(end), s2(end), s3(end)])) * 100;
            testCase.verifyLessThanOrEqual(finalSpread, 2.05, 'Final SoC spread must be <= 2.0%');
        end

        function testSafetyLimits(testCase)
            v1 = testCase.Logs.get('V_cell1').Values.Data;
            v2 = testCase.Logs.get('V_cell2').Values.Data;
            v3 = testCase.Logs.get('V_cell3').Values.Data;
            allV = [v1(:); v2(:); v3(:)];
            testCase.verifyLessThanOrEqual(max(allV), 4.25, 'Cell voltage exceeded OVP');
            testCase.verifyGreaterThanOrEqual(min(allV), 2.80, 'Cell voltage below UVP');
        end
    end
end