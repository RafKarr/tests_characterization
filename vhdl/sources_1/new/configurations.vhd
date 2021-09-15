configuration rtl_real of dsp_uart_interface is
  for rtl
      for all : generic_dsp
        use entity work.generic_dsp(Behavioral);
      end for;
    end for;
end configuration;

configuration rtl_10_p_10_c_real of dsp_uart_interface is
  for rtl_10_p_10_c
      for all : generic_dsp
        use entity work.generic_dsp(Behavioral);
      end for;
    end for;
end configuration;

configuration rtl_3_p_1_c_real of dsp_uart_interface is
  for rtl_3_p_1_c
    for all : generic_dsp
      use entity work.generic_dsp(Behavioral);
    end for;
  end for;
end configuration rtl_3_p_1_c_real;

configuration rtl_5_p_1_c_real of dsp_uart_interface is
  for rtl_5_p_1_c
    for all : generic_dsp
      use entity work.generic_dsp(Behavioral);
    end for;
  end for;
end configuration rtl_5_p_1_c_real;

configuration rtl_10_p_1_c_real of dsp_uart_interface is
  for rtl_10_p_1_c
    for all : generic_dsp
      use entity work.generic_dsp(Behavioral);
    end for;
  end for;
end configuration rtl_10_p_1_c_real;