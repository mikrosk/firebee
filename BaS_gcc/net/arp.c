/*
 * File:        arp.c
 * Purpose:     Address Resolution Protocol routines.
 *
 * Notes:
 */

#include "net.h"
#include "net_timer.h"
#include "bas_printf.h"
#include <stdbool.h>
#include <stddef.h>

//#define DEBUG
#include "debug.h"

#define TIMER_NETWORK 3

static uint8_t *arp_find_pair(ARP_INFO *arptab, uint16_t protocol, uint8_t *hwa, uint8_t *pa)
{
    /*
     * This function searches through the ARP table for the
     * specified <protocol,hwa> or <protocol,pa> address pair.
     * If it is found, then a a pointer to the non-specified
     * address is returned.  Otherwise NULL is returned.
     * If you pass in <protocol,pa> then you get <hwa> out.
     * If you pass in <protocol,hwa> then you get <pa> out.
     */
    int slot, i, match = false;
    uint8_t *rvalue;

    if (((hwa == 0) && (pa == 0)) || (arptab == 0))
        return NULL;

    rvalue = NULL;

    /*
     * Check each protocol address for a match
     */
    for (slot = 0; slot < arptab->tab_size; slot++)
    {
        if ((arptab->table[slot].longevity != ARP_ENTRY_EMPTY) &&
                (arptab->table[slot].protocol == protocol))
        {
            match = true;
            if (hwa != 0)
            {
                /*
                 * Check the Hardware Address field
                 */
                rvalue = &arptab->table[slot].pa[0];
                for (i = 0; i < arptab->table[slot].hwa_size; i++)
                {
                    if (arptab->table[slot].hwa[i] != hwa[i])
                    {
                        match = false;
                        break;
                    }
                }
            }
            else
            {
                /*
                 * Check the Protocol Address field
                 */
                rvalue = &arptab->table[slot].hwa[0];
                for (i = 0; i < arptab->table[slot].pa_size; i++)
                {
                    if (arptab->table[slot].pa[i] != pa[i])
                    {
                        match = false;
                        break;
                    }
                }
            }
            if (match)
            {
                break;
            }
        }
    }

    if (match)
        return rvalue;
    else
        return NULL;
}

void arp_merge(ARP_INFO *arptab, uint16_t protocol, int hwa_size, uint8_t *hwa,
        int pa_size, uint8_t *pa, int longevity)
{
    /*
     * This function merges an entry into the ARP table.  If
     * either piece is NULL, the function exits, otherwise
     * the entry is merged or added, provided there is space.
     */
    int i, slot;
    uint8_t *ta;

    if ((hwa == NULL) || (pa == NULL) || (arptab == NULL) ||
            ((longevity != ARP_ENTRY_TEMP) &&
             (longevity != ARP_ENTRY_PERM)))
    {
        return;
    }

    /* First search ARP table for existing entry */
    if ((ta = arp_find_pair(arptab,protocol,NULL,pa)) != 0)
    {
        /* Update hardware address */
        for (i = 0; i < hwa_size; i++)
            ta[i] = hwa[i];
        return;
    }

    /* Next try to find an empty slot */
    slot = -1;
    for (i = 0; i < MAX_ARP_ENTRY; i++)
    {
        if (arptab->table[i].longevity == ARP_ENTRY_EMPTY)
        {
            slot = i;
            break;
        }
    }

    /* if no empty slot was found, pick a temp slot */
    if (slot == -1)
    {
        for (i = 0; i < MAX_ARP_ENTRY; i++)
        {
            if (arptab->table[i].longevity == ARP_ENTRY_TEMP)
            {
                slot = i;
                break;
            }
        }
    }

    /* if after all this, still no slot found, add in last slot */
    if (slot == -1)
        slot = (MAX_ARP_ENTRY - 1);

    /* add the entry into the slot */
    arptab->table[slot].protocol = protocol;

    arptab->table[slot].hwa_size = (uint8_t) hwa_size;
    for (i = 0; i < hwa_size; i++)
        arptab->table[slot].hwa[i] = hwa[i];

    arptab->table[slot].pa_size = (uint8_t) pa_size;
    for (i = 0; i < pa_size; i++)
        arptab->table[slot].pa[i] = pa[i];

    arptab->table[slot].longevity = longevity;
}


void arp_remove(ARP_INFO *arptab, uint16_t protocol, uint8_t *hwa, uint8_t *pa)
{
    /*
     * This function removes an entry from the ARP table.  The
     * ARP table is searched according to the non-NULL address
     * that is provided.
     */
    int slot, i, match;

    if (((hwa == 0) && (pa == 0)) || (arptab == 0))
        return;

    /* check each hardware adress for a match */
    for (slot = 0; slot < arptab->tab_size; slot++)
    {
        if ((arptab->table[slot].longevity != ARP_ENTRY_EMPTY) &&
                (arptab->table[slot].protocol == protocol))
        {
            match = true;
            if (hwa != 0)
            {
                /* Check Hardware Address field */
                for (i = 0; i < arptab->table[slot].hwa_size; i++)
                {
                    if (arptab->table[slot].hwa[i] != hwa[i])
                    {
                        match = false;
                        break;
                    }
                }
            }
            else
            {
                /* Check Protocol Address field */
                for (i = 0; i < arptab->table[slot].pa_size; i++)
                {
                    if (arptab->table[slot].pa[i] != pa[i])
                    {
                        match = false;
                        break;
                    }
                }
            }
            if (match)
            {
                for (i = 0; i < arptab->table[slot].hwa_size; i++)
                    arptab->table[slot].hwa[i] = 0;
                for (i = 0; i < arptab->table[slot].pa_size; i++)
                    arptab->table[slot].pa[i] = 0;
                arptab->table[slot].longevity = ARP_ENTRY_EMPTY;
                break;
            }
        }
    }
}

void arp_request(NIF *nif, uint8_t *pa)
{
    /*
     * This function broadcasts an ARP request for the protocol
     * address "pa"
     */
    uint8_t *addr;
    NBUF *pNbuf;
    arp_frame_hdr *arpframe;
    int i, result;

    pNbuf = nbuf_alloc();
    if (pNbuf == NULL)
    {
        dbg("could not allocate Tx buffer\n");
        return;
    }

    arpframe = (arp_frame_hdr *)&pNbuf->data[ARP_HDR_OFFSET];

    /* Build the ARP request packet */
    arpframe->ar_hrd = ETHERNET;
    arpframe->ar_pro = ETH_FRM_IP;
    arpframe->ar_hln = 6;
    arpframe->ar_pln = 4;
    arpframe->opcode = ARP_REQUEST;

    addr = &nif->hwa[0];
    for (i = 0; i < 6; i++)
        arpframe->ar_sha[i] = addr[i];

    addr = ip_get_myip(nif_get_protocol_info(nif,ETH_FRM_IP));
    for (i = 0; i < 4; i++)
        arpframe->ar_spa[i] = addr[i];

    for (i = 0; i < 6; i++)
        arpframe->ar_tha[i] = 0x00;

    for (i = 0; i < 4; i++)
        arpframe->ar_tpa[i] = pa[i];

    pNbuf->length = ARP_HDR_LEN;

    /* Send the ARP request */
    dbg("sending ARP request\r\n");
    result = nif->send(nif, nif->broadcast, nif->hwa, ETH_FRM_ARP, pNbuf);

    if (result == 0)
        nbuf_free(pNbuf);
}

static int arp_resolve_pa(NIF *nif, uint16_t protocol, uint8_t *pa, uint8_t **ha)
{
    /*
     * This function accepts a pointer to a protocol address and
     * searches the ARP table for a hardware address match.  If no
     * no match found, false is returned.
     */
    ARP_INFO *arptab;

    if ((pa == NULL) || (nif == NULL) || (protocol == 0))
        return 0;

    arptab = nif_get_protocol_info (nif,ETH_FRM_ARP);
    *ha = arp_find_pair(arptab,protocol,0,pa);

    if (*ha == NULL)
        return 0;
    else
        return 1;
}

uint8_t *arp_resolve(NIF *nif, uint16_t protocol, uint8_t *pa)
{
    int i;
    uint8_t *hwa;

    /*
     * Check to see if the necessary MAC-to-IP translation information
     * is in table already
     */
    if (arp_resolve_pa(nif, protocol, pa, &hwa))
        return hwa;

    /*
     * Ok, it's not, so we need to try to obtain it by broadcasting
     * an ARP request.  Hopefully the desired host is listening and
     * will respond with it's MAC address
     */
    for (i = 0; i < 3; i++)
    {
        arp_request(nif, pa);

        timer_set_secs(TIMER_NETWORK, ARP_TIMEOUT);
        while (timer_get_reference(TIMER_NETWORK))
        {
            dbg("try to resolve %d.%d.%d.%d\r\n",
                pa[0], pa[1], pa[2], pa[3], pa[4]);
            if (arp_resolve_pa(nif, protocol, pa, &hwa))
            {
                dbg("resolved to %02x:%02x:%02x:%02x:%02x:%02x.\r\n",
                    hwa[0], hwa[1], hwa[2], hwa[3], hwa[4], hwa[5], hwa[6]);

                return hwa;
            }
        }
    }

    return NULL;
}

void arp_init(ARP_INFO *arptab)
{
    int slot, i;

    arptab->tab_size = MAX_ARP_ENTRY;
    for (slot = 0; slot < arptab->tab_size; slot++)
    {
        for (i = 0; i < MAX_HWA_SIZE; i++)
            arptab->table[slot].hwa[i] = 0;
        for (i = 0; i < MAX_PA_SIZE; i++)
            arptab->table[slot].pa[i] = 0;
        arptab->table[slot].longevity = ARP_ENTRY_EMPTY;
        arptab->table[slot].hwa_size = 0;
        arptab->table[slot].pa_size = 0;
    }
}

void arp_handler(NIF *nif, NBUF *pNbuf)
{
    /*
     * ARP protocol handler
     */
    uint8_t *addr;
    ARP_INFO *arptab;
    int longevity;
    arp_frame_hdr *rx_arpframe, *tx_arpframe;

    arptab = nif_get_protocol_info(nif, ETH_FRM_ARP);
    rx_arpframe = (arp_frame_hdr *) &pNbuf->data[pNbuf->offset];

    /*
     * Check for an appropriate ARP packet
     */
    if ((pNbuf->length < ARP_HDR_LEN)       ||
            (rx_arpframe->ar_hrd != ETHERNET)   ||
            (rx_arpframe->ar_hln != 6)          ||
            (rx_arpframe->ar_pro != ETH_FRM_IP) ||
            (rx_arpframe->ar_pln != 4))
    {
        dbg("received packet is not an ARP packet, discard it\r\n");
        nbuf_free(pNbuf);
        return;
    }

    /*
     * Check to see if it was addressed to me - if it was, keep this
     * ARP entry in the table permanently; if not, mark it so that it
     * can be displaced later if necessary
     */
    addr = ip_get_myip(nif_get_protocol_info(nif,ETH_FRM_IP));
    if ((rx_arpframe->ar_tpa[0] == addr[0]) &&
            (rx_arpframe->ar_tpa[1] == addr[1]) &&
            (rx_arpframe->ar_tpa[2] == addr[2]) &&
            (rx_arpframe->ar_tpa[3] == addr[3]) )
    {
        dbg("received ARP packet is a permanent one, store it\r\n");
        longevity = ARP_ENTRY_PERM;
    }
    else
    {
        dbg("received ARP packet was not addressed to us, keep only temporarily\r\n");
        longevity = ARP_ENTRY_TEMP;
    }

    /*
     * Add ARP info into the table
     */
    arp_merge(arptab,
            rx_arpframe->ar_pro,
            rx_arpframe->ar_hln,
            &rx_arpframe->ar_sha[0],
            rx_arpframe->ar_pln,
            &rx_arpframe->ar_spa[0],
            longevity
            );

    switch (rx_arpframe->opcode)
    {
        case ARP_REQUEST:
            /*
             * Check to see if request is directed to me
             */
            if ((rx_arpframe->ar_tpa[0] == addr[0]) &&
                    (rx_arpframe->ar_tpa[1] == addr[1]) &&
                    (rx_arpframe->ar_tpa[2] == addr[2]) &&
                    (rx_arpframe->ar_tpa[3] == addr[3]) )
            {
                dbg("received arp request directed to us, replying\r\n");
                /*
                 * Reuse the current network buffer to assemble an ARP reply
                 */
                tx_arpframe = (arp_frame_hdr *)&pNbuf->data[ARP_HDR_OFFSET];

                /*
                 * Build new ARP frame from the received data
                 */
                tx_arpframe->ar_hrd = ETHERNET;
                tx_arpframe->ar_pro = ETH_FRM_IP;
                tx_arpframe->ar_hln = 6;
                tx_arpframe->ar_pln = 4;
                tx_arpframe->opcode = ARP_REPLY;
                tx_arpframe->ar_tha[0] = rx_arpframe->ar_sha[0];
                tx_arpframe->ar_tha[1] = rx_arpframe->ar_sha[1];
                tx_arpframe->ar_tha[2] = rx_arpframe->ar_sha[2];
                tx_arpframe->ar_tha[3] = rx_arpframe->ar_sha[3];
                tx_arpframe->ar_tha[4] = rx_arpframe->ar_sha[4];
                tx_arpframe->ar_tha[5] = rx_arpframe->ar_sha[5];
                tx_arpframe->ar_tpa[0] = rx_arpframe->ar_spa[0];
                tx_arpframe->ar_tpa[1] = rx_arpframe->ar_spa[1];
                tx_arpframe->ar_tpa[2] = rx_arpframe->ar_spa[2];
                tx_arpframe->ar_tpa[3] = rx_arpframe->ar_spa[3];

                /*
                 * Now copy in the new information
                 */
                addr = &nif->hwa[0];
                tx_arpframe->ar_sha[0] = addr[0];
                tx_arpframe->ar_sha[1] = addr[1];
                tx_arpframe->ar_sha[2] = addr[2];
                tx_arpframe->ar_sha[3] = addr[3];
                tx_arpframe->ar_sha[4] = addr[4];
                tx_arpframe->ar_sha[5] = addr[5];

                addr = ip_get_myip(nif_get_protocol_info(nif,ETH_FRM_IP));
                tx_arpframe->ar_spa[0] = addr[0];
                tx_arpframe->ar_spa[1] = addr[1];
                tx_arpframe->ar_spa[2] = addr[2];
                tx_arpframe->ar_spa[3] = addr[3];

                /*
                 * Save the length of my packet in the buffer structure
                 */
                pNbuf->length = ARP_HDR_LEN;

                nif->send(nif,
                        &tx_arpframe->ar_tha[0],
                        &tx_arpframe->ar_sha[0],
                        ETH_FRM_ARP,
                        pNbuf);
            }
            else
            {
                dbg("ARP request not addressed to us, discarding\r\n");
                nbuf_free(pNbuf);
            }
            break;

        case ARP_REPLY:
            /*
             * The ARP Reply case is already taken care of
             */

            /* missing break is intentional */

        default:
            nbuf_free(pNbuf);
            break;
    }

    return;
}
