d %>%
  tidyr::pivot_longer(cols = temperature:sound)%>%
  filter(name %in% c('temperature','humidity','pressure','UVB','light','sound','PM2.5')) %>%
  mutate(timestamp, as.POSIXct(timestamp)) %>%
  ggplot(aes(x=timestamp,y=value)) +
  geom_point() +
  facet_grid(name~.,scales = 'free_y') +
  theme(strip.text.y = element_text(angle = 0)) +
  #scale_x_datetime(breaks = scales::breaks_pretty(10))+
  labs(y=NULL,x=NULL)