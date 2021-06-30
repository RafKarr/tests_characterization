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