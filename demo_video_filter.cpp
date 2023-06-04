/*****************************************************************************
 * demo_video_filter.c : A filter that does nothing
 *****************************************************************************
 * Copyright (C) 2020 Maxim Biro
 *
 * Authors: Maxim Biro <nurupo.contributions@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/
#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include <vlc_common.h>
#include <vlc_filter.h>
#include <vlc_plugin.h>
#include <vector>

static int Create(vlc_object_t *);

static void Destroy(vlc_object_t *);

struct  filter_sys_t {
    std::vector<int> test_vector;
};

vlc_module_begin()

set_description("Demo video filter")
set_shortname("Demo video filter")
set_capability("video filter", 0)
set_category(CAT_VIDEO)
set_subcategory(SUBCAT_VIDEO_VFILTER)
set_callbacks(Create, Destroy
)

vlc_module_end()

static picture_t *filter(filter_t *p_filter, picture_t *p_pic_in) {
    // debug
    auto *p_sys_1 = static_cast<filter_sys_t *>(p_filter->p_sys);
    p_sys_1->test_vector.push_back(1);
    // debug test_vector length
    msg_Info(p_filter, "test_vector length: %d", p_sys_1->test_vector.size());
    return p_pic_in;
}

static int Create(vlc_object_t *p_this) {
    // debug
    filter_t *p_filter = (filter_t *) p_this;
    filter_sys_t *p_sys;
    /* Allocate the memory needed to store the decoder's structure */
    p_filter->p_sys = p_sys = new(std::nothrow) (filter_sys_t);
    msg_Info(p_this, "Hello from demo_video_filter.c!");
    p_filter->pf_video_filter = filter;
    return VLC_SUCCESS;
}

static void Destroy(vlc_object_t *p_this) {
    // debug vector length
    filter_t *p_filter = (filter_t *) p_this;
    filter_sys_t *p_sys = p_filter->p_sys;
    msg_Info(p_this, "test_vector length: %d", p_sys->test_vector.size());
    delete p_sys;
}